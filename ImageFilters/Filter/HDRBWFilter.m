//
//  HDRBWFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/14/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "HDRBWFilter.h"
#import "GLSLFunction.h"

NSString* const kHDRBWFilterVertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 SHARPEN_UNIFORMS()
 SHARPEN_VARYINGS()
 
 void main()
 {
     gl_Position = position;
     SHARPEN_INIT(1.3);
 }
 );

NSString* const kHDRBWFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor = vec4(181.0/255.0,181.0/255.0,181.0/255.0,1.0);
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_Desaturate(textureColor,1.0);
     
     vec4 pass2 = fn_ShadowAndHighlights(pass1,0.4,1.0);
     
     vec4 pass3 = mix(pass2,blend_Multiple(pass2,fillColor),0.15);
     
     vec4 pass4 = fn_Desaturate(fn_Sharpen(inputImageTexture,textureCoordinate),1.0);
     
     gl_FragColor = mix(pass3,blend_Overlay(pass3,pass4),0.7);
 }
 );

@implementation HDRBWFilter

+ (NSString *)filterName
{
    return @"HDR BW";
}

- (id)init
{
    self = [super initWithVertexShaderFromString:kHDRBWFilterVertShader fragmentShaderFromString:kHDRBWFilterFragShader];
    if (self)
    {
        
    }
    return self;
}

@end
