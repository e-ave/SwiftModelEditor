//
//  GameViewController.swift
//  ModelViewer
//
//  Created by temp on 3/19/17.
//  Copyright © 2017 eave. All rights reserved.
//

import GLKit
import OpenGLES

func BUFFER_OFFSET(_ i: Int) -> UnsafeRawPointer? {
    return UnsafeRawPointer(bitPattern: i)
}

let UNIFORM_MODELVIEW_MATRIX = 0
let UNIFORM_PROJECTION_MATRIX = 1
let UNIFORM_NORMAL_MATRIX = 2
var uniforms = [GLint](repeating: 0, count: 3)

class GameViewController: GLKViewController {
    
    
    var program: GLuint = 0
    
    var modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    var normalMatrix: GLKMatrix3 = GLKMatrix3Identity
    
    var currentRay: Ray = Ray()
    var checkForIntersection: Bool = false
    
    var interactionMode: InteractionMode = .rotation// default interaction mode
    var rotationX: Float = 0
    var rotationY: Float = 0
    var rotationZ: Float = 0
    var translation = GLKVector3Make(0, 0, 0)
    var extruding: Bool = false
    var scale: Float = 1
    var lastScale: Float = 1
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var selectedTriangleIdBuffer: GLuint = 0
    var selectedVertices: [GLfloat] = []
    var lastSelectedFace: GLfloat = -1
    var lastToLastSelectedFace: GLfloat = -1
    var meshData: [GLfloat] = []
    var trackedTaps = [IdentifiablePoint]()
    var context: EAGLContext? = nil
    
    // Primitives for the primitive picker
    var primitivePicker = CZPickerView(headerTitle: "Add New Primitive", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")!
    let shapes = ["Cube", "Cone", "Cylinder", "Pyramid", "Sphere", "Icosphere", "Torus", "Tube", "Plane"]
    let shapeIcons = [UIImage(named: "Cube")!, UIImage(named: "Cone")!, UIImage(named: "Cylinder")!, UIImage(named: "Pyramid")!, UIImage(named: "Sphere")!, UIImage(named: "IcoSphere")!, UIImage(named: "Torus")!, UIImage(named: "Tube")!, UIImage(named: "Plane")!]
    let primTypes: [ProceduralPrimitive] = [ProceduralCube(), ProceduralCone(), ProceduralCylinder(), ProceduralCone(sides: 4),ProceduralSphere(), ProceduralIcosphere(), ProceduralTorus(), ProceduralTube(), ProceduralPlane()]
    
    @IBOutlet weak var currentModeLabel: UILabel!
    
    deinit {
        self.tearDownGL()
        
        if EAGLContext.current() === self.context {
            EAGLContext.setCurrent(nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the primitive picker
        primitivePicker.delegate = self
        primitivePicker.dataSource = self
        primitivePicker.needFooterView = false
        
        // Set up observers and gesture recognizers
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsUpdated(_:)), name: UserDefaults.didChangeNotification, object: nil)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinched))
        self.view.addGestureRecognizer(pinch)
        
        self.view.isMultipleTouchEnabled = true
        
        self.context = EAGLContext(api: .openGLES2)//Maybe convert to GLES3 later
        
        if !(self.context != nil) {
            print("Failed to create ES context")
        }
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24
        let msaaEnabled = UserDefaults.standard.bool(forKey: SettingsKeys.ANTIALIASING)
        if msaaEnabled {
            view.drawableMultisample = .multisample4X
        }
        
        // Add a torus by default. Could (should?) be disabled
        let defaultPrim: ProceduralPrimitive = ProceduralTorus()
        defaultPrim.generate()
        meshData = defaultPrim.toFloatBuffer()
        selectedVertices = [GLfloat](repeating: 0, count: meshData.count/13)
        
        self.setupGL()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.current() === self.context {
                EAGLContext.setCurrent(nil)
            }
            self.context = nil
        }
    }
    
    /// Converts a 2D touch into a 3D ray.
    /// Uses glUnproject. The math behind doing this manually
    /// is not too complicated, but it adds a lot of unneccesary 
    /// code since this doesnt neccisarily need to be understood.
    ///
    /// - Parameters:
    ///   - location: The touched point we want to project the ray from
    ///   - dragging: Whether or not the current touch is being dragged
    func projectRay(at location: CGPoint, dragging: Bool = false) {
        let locX = location.x * UIScreen.main.scale//adjust for retina
        let locY = location.y * UIScreen.main.scale//adjust for retina
        
        var viewport = [GLint](repeating: GLint(), count: 4)
        glGetIntegerv(GLenum(GL_VIEWPORT), &viewport)
        
        let x = Float(locX)
        let y = Float(locY) - Float(viewport[3])//opengl inverted coords
        var success: Bool = false
        let near: GLKVector3 = GLKMathUnproject(GLKVector3Make(x, -y, 0.0), modelViewMatrix, projectionMatrix, &viewport[0], &success)
        let far: GLKVector3 = GLKMathUnproject(GLKVector3Make(x, -y, 1.0), modelViewMatrix, projectionMatrix, &viewport[0], &success)
        
        // Create the ray
        var direction: GLKVector3 = GLKVector3Subtract(far, near)
        direction = GLKVector3Normalize(direction)
        
        currentRay.setDirection(direction)
        currentRay.setOrigin(near)
        currentRay.setDragging(dragging)
        checkForIntersection = true

    }
    
    
    // MARK: - Gestures and touches
    
    func pinched(_ sender: UIPinchGestureRecognizer) {
        if sender.state != .ended {
            if interactionMode == .edit {
                //TODO: Actually scale down vertices in edit mode
            } else {
                scale = scale - (lastScale - Float(sender.scale))
                lastScale = Float(sender.scale)
            }
        }
    }
    
    /// Allows for tracking single touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1, let touch = touches.first {
            let loc = touch.location(in: view)
            let trackableTouch = IdentifiablePoint(origin: loc, touch: touch)
            trackedTaps.append(trackableTouch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1, let touch = touches.first {
            
            // Find the current touch in the trackedTouches array.
            // This allows this functionality to work in cases when
            // the user taps a second time without lifting their first finger.
            // A simple stack will not work because the user can for example
            // create the following input: tap1, tap2, lift1, lift2
            if let pairLoc = trackedTaps.first(where:{ $0.touch == touch }) {
                let loc = touch.location(in: view)
                
                // If the touch origin and the current location
                // are at the same coordinates, we havent dragged
                // and can select the current face
                if loc == pairLoc.origin {
                    projectRay(at: loc)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            switch interactionMode {
            case .rotation:
                let previousLocation = touch.previousLocation(in: self.view)
                
                let dx = location.x - previousLocation.x
                let dy = location.y - previousLocation.y
                
                rotationY -= Float(dx) * 0.05
                rotationX += Float(dy) * 0.05
                break;
                
            case .selection:
                projectRay(at: location, dragging: true)
                break;
                
            case .edit:
                let previousLocation = touch.previousLocation(in: self.view)
                
                let dx = location.x - previousLocation.x
                let dy = location.y - previousLocation.y
                
                // Only extrude if there is one touch. Two or more touches
                // simply translates the selected faces.
                extruding = touches.count == 1
                
                // Set the translation from the dx and dy
                translation = GLKVector3Make(Float(dx) * 0.05, -Float(dy) * 0.05, 0)
                break;
            }
        }
    }
    
    
    // MARK: - Methods for manipulating the mesh buffer
    
    /// Adds a face to the mesh buffer
    func addFaceData(_ vA: GLKVector3, _ vB: GLKVector3, _ vC: GLKVector3, withColor col: GLKVector4) {
        meshData.append(contentsOf: [vA.x, vA.y, vA.z, vA.normalized.x, vA.normalized.y, vA.normalized.z, 0, 0, 1, col.r, col.g, col.b, col.a])
        meshData.append(contentsOf: [vB.x, vB.y, vB.z, vB.normalized.x, vB.normalized.y, vB.normalized.z, 0, 1, 0, col.r, col.g, col.b, col.a])
        
        meshData.append(contentsOf: [vC.x, vC.y, vC.z, vC.normalized.x, vC.normalized.y, vC.normalized.z, 1, 0, 0, col.r, col.g, col.b, col.a])
        selectedVertices.append(0)
        selectedVertices.append(0)
        selectedVertices.append(0)
    }
    
    /// Gets the vertices for a certain triangle
    func getFaceVertices(triangle tri: Int) -> [GLKVector3] {
        let vA = GLKVector3Make(meshData[tri * 13], meshData[tri * 13 + 1], meshData[tri * 13 + 2])
        let vB = GLKVector3Make(meshData[(tri + 1) * 13], meshData[(tri + 1) * 13 + 1], meshData[(tri + 1) * 13 + 2])
        let vC = GLKVector3Make(meshData[(tri + 2) * 13], meshData[(tri + 2) * 13 + 1], meshData[(tri + 2) * 13 + 2])
        return [vA, vB, vC]
    }
    
    /// Gets the vertex normals for a certain triangle
    func getFaceVertexNormals(triangle tri: Int) -> [GLKVector3] {
        let nA = GLKVector3Make(meshData[tri * 13 + 3], meshData[tri * 13 + 4], meshData[tri * 13 + 5])
        let nB = GLKVector3Make(meshData[(tri + 1) * 13 + 3], meshData[(tri + 1) * 13 + 4], meshData[(tri + 1) * 13 + 5])
        let nC = GLKVector3Make(meshData[(tri + 2) * 13 + 3], meshData[(tri + 2) * 13 + 4], meshData[(tri + 2) * 13 + 5])
        return [nA, nB, nC]
    }
    
    /// Gets the colors for a certain triangle
    func getFaceColors(triangle tri: Int) -> [GLKVector4] {
        let vA = GLKVector4Make(meshData[tri * 13 + 9], meshData[tri * 13 + 10], meshData[tri * 13 + 11], meshData[tri * 13 + 12])
        let vB = GLKVector4Make(meshData[(tri + 1) * 13 + 9], meshData[(tri + 1) * 13 + 10], meshData[(tri + 1) * 13 + 11], meshData[(tri + 1) * 13 + 12])
        let vC = GLKVector4Make(meshData[(tri + 2) * 13 + 9], meshData[(tri + 2) * 13 + 10], meshData[(tri + 2) * 13 + 11], meshData[(tri + 2) * 13 + 12])
        return [vA, vB, vC]
    }
    
    /// Sets the vertices for a certain triangle
    func setFaceData(triangle tri: Int, _ vA: GLKVector3, _ vB: GLKVector3, _ vC: GLKVector3) {
        // Vertex 1 of tri
        meshData[tri * 13] = vA.x
        meshData[tri * 13 + 1] = vA.y
        meshData[tri * 13 + 2] = vA.z
        
        // Vertex 2 of tri
        meshData[(tri + 1) * 13] = vB.x
        meshData[(tri + 1) * 13 + 1] = vB.y
        meshData[(tri + 1) * 13 + 2] = vB.z
        
        // Vertex 3 of tri
        meshData[(tri + 2) * 13] = vC.x
        meshData[(tri + 2) * 13 + 1] = vC.y
        meshData[(tri + 2) * 13 + 2] = vC.z
        
    }
    
    /// Selects or deselects a face.
    /// - params:
    ///     - triangle: The specified face
    ///     - dragging: Whether or not the touch that selected this face was being dragged
    func setSelectedFace(triangle tri: Int, dragging: Bool = false) {
        let triangle = GLfloat(tri)
        
        // We don't want to rapidly select and deselect triangles in selection mode and we need to
        // allow for a grace period for recently selected triangles to make selection more convenient
        if interactionMode == .selection && (triangle == lastSelectedFace || triangle == lastToLastSelectedFace) && dragging {
            return
        }
        
        // Unselect the face if it's already selected or select the face
        // by setting the selectedVertices to the face ID
        if selectedVertices[tri] == 1 {
            selectedVertices[tri] = 0
            selectedVertices[tri + 1] = 0
            selectedVertices[tri + 2] = 0
        } else {
            selectedVertices[tri] = 1
            selectedVertices[tri + 1] = 1
            selectedVertices[tri + 2] = 1
        }
        
        // Set the faces for the grace period
        lastToLastSelectedFace = lastSelectedFace
        lastSelectedFace = triangle
        
        // Update the selected triangle buffer
        var newVerticesData: [GLfloat] = [selectedVertices[tri], selectedVertices[tri + 1], selectedVertices[tri + 2]]
        glBindVertexArrayOES(vertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), selectedTriangleIdBuffer)
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * tri, GLsizeiptr(MemoryLayout<GLfloat>.size * 3), &newVerticesData)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    
    // MARK: - IBActions
    
    /// Used to unwinding from the settings menu back to the gameviewcontroller.
    /// Nothing needs to be inside this method.
    @IBAction func unwindToGameViewController(segue: UIStoryboardSegue) { }
    
    /// Action triggered by tapping the selection button on the storyboard.
    /// Changes the interaction mode to selection and changes the current
    /// mode label to match.
    @IBAction func selectionButtonClicked(_ sender: UIButton) {
        interactionMode = .selection
        currentModeLabel.text = "Selection"
    }
    
    /// Action triggered by tapping the rotation button on the storyboard.
    /// Changes the interaction mode to rotation and changes the current
    /// mode label to match.
    @IBAction func rotationButtonClicked(_ sender: UIButton) {
        interactionMode = .rotation
        currentModeLabel.text = "Rotation"
    }
    
    /// Action triggered by tapping the edit button on the storyboard.
    /// Changes the interaction mode to edit and changes the current
    /// mode label to match.
    @IBAction func editButtonClicked(_ sender: UIButton) {
        interactionMode = .edit
        currentModeLabel.text = "Edit"
    }

    /// Action triggered by tapping the add button on the storyboard.
    /// Opens the picker for selecting a new primitive object to add.
    @IBAction func addPrimitiveButtonClicked(_ sender: UIButton) {
        primitivePicker.show()
    }
    
    
    /// Action triggered by tapping the delete button on the storyboard.
    /// This method loops through and deletes the currently selected faces
    /// from the mesh
    @IBAction func deleteButtonClicked(_ sender: Any) {
        var toDelete: [Int] = []
        
        // Loop through the mesh and add the selected vertices
        // to the array backwards (to avoid out of bounds error when deleting)
        for tri in stride(from: 0, to: meshData.count / 13, by: 3) {
            if selectedVertices[tri] == 1 {
                toDelete.insert(tri, at: 0)
            }
        }

        // Loop through all of the vertices we are going to delete
        for tri in toDelete {
            
            // Go through 3 times, 3 vertices per face
            for _ in 0 ..< 3 {
                
                // Remove all 13 values from the vertex buffer
                for _ in 0 ..< 13 {
                    meshData.remove(at: tri * 13)
                }
                selectedVertices.remove(at: tri)
            }
        }

        
        // Updating the vbos
        glBindVertexArrayOES(vertexArray)// bind vao
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)//bind vbo
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * meshData.count), &meshData, GLenum(GL_DYNAMIC_DRAW))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(0))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(12))
        glVertexAttribPointer(CustomVertexAttrib.barycentric.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(24))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(36))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), selectedTriangleIdBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * selectedVertices.count), &selectedVertices, GLenum(GL_DYNAMIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
    }
    
    /// Action triggered by tapping the select all button on the storyboard.
    /// This method loops through and selects every face
    @IBAction func selectAllClicked(_ sender: Any) {
        
        // Loop through and set the selected vertices
        for tri in 0 ..< selectedVertices.count {
            selectedVertices[tri] = 1
        }
        
        // Update the selected triangle buffer
        glBindVertexArrayOES(vertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), selectedTriangleIdBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * selectedVertices.count), &selectedVertices, GLenum(GL_DYNAMIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    /// Action triggered by tapping the deselect all button on the storyboard.
    /// This method loops through and deselects every face
    @IBAction func unselectClicked(_ sender: Any) {
        
        // Loop through and unset the selected vertices
        for tri in 0 ..< selectedVertices.count {
            selectedVertices[tri] = 0
        }
        
        // Update the selected triangle buffer
        glBindVertexArrayOES(vertexArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), selectedTriangleIdBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * selectedVertices.count), &selectedVertices, GLenum(GL_DYNAMIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    
    // MARK: - In app settings
    
    /// Called when the user defaults are updated (Settings changed)
    /// Applies the updated settings.
    func defaultsUpdated(_ notification: Notification) {
        if let defaults = notification.object as? UserDefaults {
            if defaults.bool(forKey: SettingsKeys.ANTIALIASING) {
                let view = self.view as! GLKView
                if view.drawableMultisample == .multisampleNone {
                    view.drawableMultisample = .multisample4X
                }
            } else {
                let view = self.view as! GLKView
                if view.drawableMultisample == .multisample4X {
                    view.drawableMultisample = .multisampleNone
                }
            }
        }
    }
    
    
    // MARK: - Methods for setting up and destroying GL
    
    func setupGL() {
        EAGLContext.setCurrent(self.context)
        
        if(self.loadShaders() == false) {
            print("Failed to load shaders")
        }
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        // Generate and bind the vao
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        // Generate and bind the selected vertex vbo
        glGenBuffers(1, &selectedTriangleIdBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), selectedTriangleIdBuffer)
        
        // Set the data for the selected vertex vbo
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * selectedVertices.count), &selectedVertices, GLenum(GL_DYNAMIC_DRAW))
        
        // Set the selected vertices vertex attribs
        glEnableVertexAttribArray(CustomVertexAttrib.selectedTriangle.rawValue)
        glVertexAttribPointer(CustomVertexAttrib.selectedTriangle.rawValue, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, BUFFER_OFFSET(0))
        
        // Generate and bind the main vbo which contains mesh data
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        
        // Set the data for the mesh
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * meshData.count), &meshData, GLenum(GL_DYNAMIC_DRAW))
        
        // Set the vertex attribs for vertex position
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(0))
        
        // Set the vertex attribs for vertex normals
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(12))
        
        // Set the vertex attribs for barycentric coords
        glEnableVertexAttribArray(CustomVertexAttrib.barycentric.rawValue)
        glVertexAttribPointer(CustomVertexAttrib.barycentric.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(24))
        
        // Set the vertex attribs for color
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(36))
        
        // Unbind the buffers
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    func tearDownGL() {
        EAGLContext.setCurrent(self.context)
        
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &selectedTriangleIdBuffer)
        glDeleteVertexArraysOES(1, &vertexArray)
        
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
    }
    
    
    // MARK: - GLKView and GLKViewController delegate methods
    
    func update() {
        let aspect = fabsf(Float(self.view.bounds.size.width / self.view.bounds.size.height))
        projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1, 100.0)
        
        let baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -4.0)
        
        // Compute the model view matrix for the object rendered with ES2
        modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, 0.0)
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, rotationX)
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, rotationY)
        //modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, rotationX*rotationY)
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale, scale, scale)
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix)
        
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil)
        
        
        if translation != GLKVector3.zero {
            // Multiply the translation vector by the modelviewmatrix so we can move even
            // if we've rotated the view
            translation = GLKMatrix4MultiplyVector3(modelViewMatrix, translation)
            print("preparing to translate selected vertices by \(translation.x), \(translation.y), \(translation.z)")
            
            
            // Loop through and find the selected triangles
            var movedFaces: [[GLKVector3]] = []
            var movedVerts: [GLKVector3] = []
            var movedVertColors:  [GLKVector4] = []
            for tri in stride(from: 0, to: meshData.count / 13, by: 3) {
                
                if selectedVertices[tri] == 1 {
                    
                    // Get the face and colors of the selected triangle
                    let colors: [GLKVector4] = getFaceColors(triangle: tri)
                    let face: [GLKVector3] = getFaceVertices(triangle: tri)
                    
                    // Add the translation to the vertices
                    let vA = face[0] + translation
                    let vB = face[1] + translation
                    let vC = face[2] + translation
                    
                    // If we're extruding we need to save the vertices, faces, and vertex colors
                    // of the faces before the translation
                    if extruding {
                        movedFaces.append(face)
                        movedVerts.append(contentsOf: face)
                        movedVertColors.append(contentsOf: colors)
                    }
                    
                    // Set the translated vertices
                    setFaceData(triangle: tri, vA, vB, vC)
 
                }
            }
            
            
            if extruding {
                
                
                // Determine which vertices to extrude by determining
                // how many times the vertices are shared
                var vertsToExtrude: [GLKVector3] = []
                for vertex in movedVerts {
                    var shareCount = 0
                    
                    for face in movedFaces {
                        if vertex == face[0] || vertex == face[1] || vertex == face[2] {
                            shareCount += 1
                        }
                    }
                    
                    // If the vertex is shared less than 4 times we should
                    // extrude it
                    if shareCount < 4 {
                        if !vertsToExtrude.contains(vertex) {
                            vertsToExtrude.append(vertex)
                        }
                    }
                    
                }

                // Loop through the vertices and connect the translated vertices
                // to the original vertices with triangles to complete the extrusion
                for vertex in stride(from: 0, to: movedVerts.count, by: 3) {
                    
                    if vertsToExtrude.contains(movedVerts[vertex]) {
                        addFaceData(movedVerts[vertex], movedVerts[vertex] + translation, movedVerts[vertex + 1] + translation, withColor: movedVertColors[vertex])
                        addFaceData(movedVerts[vertex + 1], movedVerts[vertex + 1] + translation, movedVerts[vertex], withColor: movedVertColors[vertex + 1])
                        
                      
                        addFaceData(movedVerts[vertex], movedVerts[vertex] + translation, movedVerts[vertex + 2] + translation, withColor: movedVertColors[vertex])
                        addFaceData(movedVerts[vertex + 2], movedVerts[vertex + 2] + translation, movedVerts[vertex], withColor: movedVertColors[vertex + 2])
                  
                        addFaceData(movedVerts[vertex + 1], movedVerts[vertex + 1] + translation, movedVerts[vertex + 2] + translation, withColor: movedVertColors[vertex + 1])
                        addFaceData(movedVerts[vertex + 2], movedVerts[vertex + 2] + translation, movedVerts[vertex + 1], withColor: movedVertColors[vertex + 2])
                    }
                }
            }
            
            // Reset the translation to zero
            translation = GLKVector3.zero
            
            
            // Update the mesh data and selected triangle buffers
            glBindVertexArrayOES(vertexArray)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * meshData.count), &meshData, GLenum(GL_DYNAMIC_DRAW))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(0))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(12))
            glVertexAttribPointer(CustomVertexAttrib.barycentric.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(24))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 52, BUFFER_OFFSET(36))
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), selectedTriangleIdBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * selectedVertices.count), &selectedVertices, GLenum(GL_DYNAMIC_DRAW))
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            glBindVertexArrayOES(0)
        
        
        }
        
        // Check if a triangle has been selected
        if checkForIntersection {
            
            // Make a list to store all possible intersections
            var possibleIntersections: [(GLKVector3, Int)] = []
            
            for tri in stride(from: 0, to: meshData.count / 13, by: 3) {
                
                // Get the face vertices
                let face: [GLKVector3] = getFaceVertices(triangle: tri)
                let vert1 = face[0]
                let vert2 = face[1]
                let vert3 = face[2]
                
                // Check if the ray is intersecting the face
                if let inter = RayTest.algebraicTest(origin: currentRay.getOrigin(), direction: currentRay.getDirection(), vertexA: vert1, vertexB: vert2, vertexC: vert3) {
                    checkForIntersection = false
                    possibleIntersections.append((inter, tri))
                }
                

            }
            // Now search through all of the intersections and find the one
            // closest to the near plane. That's our intersection.
            if possibleIntersections.count > 0 {
                
                var closestIntersection: (GLKVector3, Int) = possibleIntersections[0]
                var closestDistance: Float = Float.infinity
                for intersection in possibleIntersections {
            
                    let dist = sqrt(pow(currentRay.getOrigin().x - intersection.0.x, 2) + pow(currentRay.getOrigin().y - intersection.0.y, 2) + pow(currentRay.getOrigin().z - intersection.0.z, 2))
                    if dist < closestDistance {
                        closestDistance = dist
                        closestIntersection = intersection
                    }
                }
                
                // Now that we found the closest intersection, set the face as selected
                setSelectedFace(triangle: closestIntersection.1, dragging: currentRay.getDragging())
            }
        }
        
        
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.2,0.2,0.2, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        
        glBindVertexArrayOES(vertexArray)
        
        // Render the object again with ES2
        glUseProgram(program)
        
        withUnsafePointer(to: &modelViewMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 16, {
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, $0)
            })
        })
        withUnsafePointer(to: &projectionMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 16, {
                glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, 0, $0)
            })
        })
        withUnsafePointer(to: &normalMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 9, {
                glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, $0)
            })
        })
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(meshData.count / 13))
    }
    
    // MARK: -  OpenGL ES 2 shader compilation
    
    func loadShaders() -> Bool {
        var vertShader: GLuint = 0
        var fragShader: GLuint = 0
        var vertShaderPathname: String
        var fragShaderPathname: String
        
        // Create shader program.
        program = glCreateProgram()
        
        // Create and compile vertex shader.
        vertShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "vsh")!
        if self.compileShader(&vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertShaderPathname) == false {
            print("Failed to compile vertex shader")
            return false
        }
        
        // Create and compile fragment shader.
        fragShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "fsh")!
        if !self.compileShader(&fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShaderPathname) {
            print("Failed to compile fragment shader")
            return false
        }
        
        // Attach vertex shader to program.
        glAttachShader(program, vertShader)
        
        // Attach fragment shader to program.
        glAttachShader(program, fragShader)
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.position.rawValue), "position")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.normal.rawValue), "normal")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.color.rawValue), "color")
        glBindAttribLocation(program, CustomVertexAttrib.barycentric.rawValue, "barycentric")
        glBindAttribLocation(program, CustomVertexAttrib.selectedTriangle.rawValue, "selectedTriangleId")
        // Link program.
        if !self.linkProgram(program) {
            print("Failed to link program: \(program)")
            
            if vertShader != 0 {
                glDeleteShader(vertShader)
                vertShader = 0
            }
            if fragShader != 0 {
                glDeleteShader(fragShader)
                fragShader = 0
            }
            if program != 0 {
                glDeleteProgram(program)
                program = 0
            }
            
            return false
        }
        
        // Get uniform locations.
        uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(program, "modelViewMatrix")
        uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(program, "projectionMatrix")
        uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(program, "normalMatrix")
        
        // Release vertex and fragment shaders.
        if vertShader != 0 {
            glDetachShader(program, vertShader)
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDetachShader(program, fragShader)
            glDeleteShader(fragShader)
        }
        
        return true
    }
    
    
    func compileShader(_ shader: inout GLuint, type: GLenum, file: String) -> Bool {
        var status: GLint = 0
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            print("Failed to load vertex shader")
            return false
        }
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        
        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        
        //#if defined(DEBUG)

        var logLength: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if 0 < logLength {
            let log = Array<GLchar>(repeating: 0, count: Int(logLength))
            log.withUnsafeBufferPointer { logPointer -> Void in
                glGetShaderInfoLog(shader, logLength, &logLength, UnsafeMutablePointer(mutating: logPointer.baseAddress))
                NSLog("Shader compile log: \n%@", String(bytesNoCopy: UnsafeMutablePointer(mutating: logPointer.baseAddress!), length: Int(logLength), encoding: String.Encoding.utf8, freeWhenDone: false)!)
                
            }
        }
        //#endif
        
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == 0 {
            glDeleteShader(shader)
            return false
        }
        return true
    }
    
    func linkProgram(_ prog: GLuint) -> Bool {
        var status: GLint = 0
        glLinkProgram(prog)
        
        //#if defined(DEBUG)
        //        var logLength: GLint = 0
        //        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        //        if logLength > 0 {
        //            var log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
        //            glGetShaderInfoLog(shader, logLength, &logLength, log)
        //            NSLog("Shader compile log: \n%s", log)
        //            free(log)
        //        }
        //#endif
        
        glGetProgramiv(prog, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            return false
        }
        
        return true
    }
    
    func validateProgram(prog: GLuint) -> Bool {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            print("Program validate log: \n\(log)")
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    }
}


extension GameViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        if pickerView == primitivePicker {
            return shapeIcons[row]
        }
        return nil
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return shapes.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return shapes[row]
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        //.passengerClass.text =
        let test: ProceduralPrimitive = primTypes[row]
        test.generate()
        let newMesh = test.toFloatBuffer()
        
        // Make sure the newly added primitive is fully selected
        for _ in stride(from: selectedVertices.count, to: selectedVertices.count + newMesh.count / 13, by: 3){
            selectedVertices.append(1)
            selectedVertices.append(1)
            selectedVertices.append(1)
        }
        
        meshData.append(contentsOf: newMesh)
        self.setupGL()
        
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
