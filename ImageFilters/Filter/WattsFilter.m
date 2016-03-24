//
//  WattsFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/13/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "WattsFilter.h"
#import "ToneCurves.h"
#import "GLSLFunction.h"

NSString* const kWattsFilterVertShader = SHADER_STRING
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

NSString* const kWattsFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor = vec4(233.0/255.0,7.0/255.0,124.0/255.0,1.0);
 
 void main()
 {
     vec4 pass1 = fn_Sharpen(inputImageTexture,textureCoordinate);
     
     vec4 pass2 = fn_Contrast(pass1,0.9);
     
     vec4 pass3 = fn_ToneCurve(pass2,toneCurveTexture);
     
     vec4 pass4 = mix(pass3,blend_Screen(pass3,fillColor),0.2);
     
     vec4 pass5 = fn_HSB(pass4,0.0,-0.015,0.0);
     
     gl_FragColor = fn_Vignette(textureCoordinate,pass5,0.5,0.75);
 }
 );

@interface WattsFilter ()
{
    GLuint uToneCurveTexture;
}

@property (nonatomic,strong) ToneCurves* curves;

@end

@implementation WattsFilter

+ (NSString *)filterName
{
    return @"Watts";
}

- (id)init
{
    self = [super initWithVertexShaderFromString:kWattsFilterVertShader fragmentShaderFromString:kWattsFilterFragShader];
    if (self)
    {
        uToneCurveTexture = [filterProgram uniformIndex:@"toneCurveTexture"];
        
        self.curves = [ToneCurves curves];
        self.curves.RedControlPoints = @[CPoint(69, 42),CPoint(209, 226)];
        self.curves.GreenControlPoints = @[CPoint(36, 51),CPoint(130, 130),CPoint(216, 230)];
        self.curves.BlueControlPoints = @[CPoint(0, 51),CPoint(255, 237)];
        [self.curves updateToneCurveTexture];
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
