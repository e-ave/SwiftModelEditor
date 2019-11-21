//
//  Shader.fsh
//  ModelViewer
//
//  Created by temp on 3/19/17.
//  Copyright © 2017 eave. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec3 barycentricVarying;
varying lowp float selectedTriangleIdVarying;

void main()
{
    lowp vec4 selectRecol = vec4(1.0, 1.0, 1.0, 1.0);
    if (selectedTriangleIdVarying > 0.01) {
        selectRecol = vec4(0.5, 1.0, 0.7, 0.05);
    }
    
    // We use barycentric coordinates for the corners of the triangles to modify
    // the color in order to create a wireframe around the faces
    lowp float min_dist = min(min(barycentricVarying.x, barycentricVarying.y), barycentricVarying.z);
    lowp float edgeIntensity = 1.0 - step(0.005, min_dist);
    gl_FragColor = edgeIntensity * vec4(0.0, 1.0, 1.0, 1.0) + (1.0 - edgeIntensity) * colorVarying * selectRecol;
}
