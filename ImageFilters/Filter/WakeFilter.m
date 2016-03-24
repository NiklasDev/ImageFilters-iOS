//
//  WakeFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/13/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "WakeFilter.h"
#import "ToneCurves.h"
#import "GLSLFunction.h"

NSString* const kWakeFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor = vec4(246.0/255.0,221.0/255.0,173.0/255.0,1.0);
 
 const vec3 minLevel = vec3(25.0 / 255.0,25.0 / 255.0,0.0);
 const vec3 gammaLevel = vec3(1.0,1.0,1.0);
 const vec3 maxLevel = vec3(255.0 / 255.0,255.0 / 255.0,255.0 / 255.0);
 
 const vec3 inLevel = vec3(0.0,0.0,120.0 / 255.0);
 const vec3 outLevel = vec3(1.0,1.0,1.0);
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_Vignette(textureCoordinate,color,0.4,1.05);
     
     vec4 pass2 = blend_Multiple(pass1,fillColor);
     
     vec4 pass3 = fn_ToneCurve(pass2,toneCurveTexture);
     
     vec4 pass4 = vec4(LevelsControl(pass3.rgb, minLevel, gammaLevel, maxLevel, inLevel, outLevel), 1.0);
     
     gl_FragColor = pass4;
 }
 );

@interface WakeFilter ()
{
    GLuint uToneCurveTexture;
}

@property (nonatomic,strong) ToneCurves* curves;

@end

@implementation WakeFilter

+ (NSString *)filterName
{
    return @"Wake";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kWakeFilterFragShader];
    if (self)
    {
        uToneCurveTexture = [filterProgram uniformIndex:@"toneCurveTexture"];
        
        self.curves = [ToneCurves curvesWithACVFileName:@"Wake"];
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
