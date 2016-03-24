//
//  HDRFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/14/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "HDRFilter.h"
#import "ToneCurves.h"
#import "GLSLFunction.h"

NSString* const kHDRFilterVertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 SHARPEN_UNIFORMS()
 SHARPEN_VARYINGS()
 
 void main()
 {
     gl_Position = position;
     SHARPEN_INIT(0.8);
 }
 );

NSString* const kHDRFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor = vec4(233.0/255.0,7.0/255.0,124.0/255.0,1.0);
 
 vec4 fn_Exposure(vec4 color, float exposure)
 {
     return vec4(color.rgb * pow(2.0, exposure), color.w);
 }
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_ShadowAndHighlights(textureColor,0.3,0.9);
     
     vec4 pass2 = fn_Sharpen(inputImageTexture,textureCoordinate);
     
     vec4 pass3 = blend_Screen(pass1,pass2);
     
     vec4 pass4 = fn_ToneCurve(pass3,toneCurveTexture);
     
     gl_FragColor = pass4;
 }
 );

@interface HDRFilter ()
{
    GLuint uToneCurveTexture;
}

@property (nonatomic,strong) ToneCurves* curves;

@end

@implementation HDRFilter

+ (NSString *)filterName
{
    return @"HDR";
}

- (id)init
{
    self = [super initWithVertexShaderFromString:kHDRFilterVertShader fragmentShaderFromString:kHDRFilterFragShader];
    if (self)
    {
        uToneCurveTexture = [filterProgram uniformIndex:@"toneCurveTexture"];
        
        self.curves = [ToneCurves curves];
        self.curves.RgbCompositeControlPoints = @[CPoint(43, 36),CPoint(203, 207)];
        //self.curves.RGBControlPoints = @[CPoint(43, 36),CPoint(203, 207)];
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
