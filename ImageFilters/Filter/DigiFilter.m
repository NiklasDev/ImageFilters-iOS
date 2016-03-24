//
//  DigiFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/17/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "DigiFilter.h"
#import "ToneCurves.h"
#import "GLSLFunction.h"

NSString* const kDigiFilterVertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 SHARPEN_UNIFORMS()
 SHARPEN_VARYINGS()
 
 void main()
 {
     gl_Position = position;
     SHARPEN_INIT(1.2);
 }
 );

NSString* const kDigiFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor = vec4(17.0/255.0,17.0/255.0,17.0/255.0,1.0);
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_Vignette(textureCoordinate,color,0.4,0.9);
     
     vec4 pass2 = fn_ToneCurve(pass1,toneCurveTexture);
     
     vec4 pass3 = blend_Hue(pass2,fillColor);
     
     vec4 pass4 = mix(pass2,pass3,0.2);
     
     vec4 pass5 = fn_Sharpen(inputImageTexture,textureCoordinate);
     
     vec4 pass6 = mix(pass4,blend_ColorDodge(pass4,pass5),0.25);
     
     gl_FragColor = pass6;
 }
 );

@interface DigiFilter ()
{
    GLuint uToneCurveTexture;
}

@property (nonatomic,strong) ToneCurves* curves;

@end

@implementation DigiFilter

+ (NSString *)filterName
{
    return @"Digi";
}

- (id)init
{
    self = [super initWithVertexShaderFromString:kDigiFilterVertShader fragmentShaderFromString:kDigiFilterFragShader];
    if (self)
    {
        uToneCurveTexture = [filterProgram uniformIndex:@"toneCurveTexture"];
        self.curves = [ToneCurves curvesWithACVFileName:@"Digi"];
    }
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture
{
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, self.curves.textureId);
    [self setInteger:4 forUniform:uToneCurveTexture program:filterProgram];
    
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates sourceTexture:sourceTexture];
}

@end
