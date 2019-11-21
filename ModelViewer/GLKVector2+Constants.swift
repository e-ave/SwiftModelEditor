//
//  GLKVector2+Constants.swift
//  ModelViewer
//
//  Created by temp on 3/25/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

/// The addition of helpful constants to GLKVector2

extension GLKVector2 {
    public static let down: GLKVector2 = GLKVector2Make(0, -1)
    public static let left: GLKVector2 = GLKVector2Make(-1, 0)
    public static let one: GLKVector2 = GLKVector2Make(1, 1)
    public static let right: GLKVector2 = GLKVector2Make(1, 0)
    public static let up: GLKVector2 = GLKVector2Make(0, 1)
    public static let zero: GLKVector2 = GLKVector2Make(0, 0)
}
