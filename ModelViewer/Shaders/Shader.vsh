//
//  Shader.vsh
//  ModelViewer
//
//  Created by temp on 3/19/17.
//  Copyright © 2017 eave. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec3 barycentric;
attribute vec4 color;
attribute float selectedTriangleId;

varying lowp vec3 barycentricVarying;
varying lowp vec4 colorVarying;
varying lowp float selectedTriangleIdVarying;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    selectedTriangleIdVarying = selectedTriangleId;
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    colorVarying = color * nDotVP;
    
    barycentricVarying = barycentric;
    gl_Position = projectionMatrix * modelViewMatrix * position;
}
