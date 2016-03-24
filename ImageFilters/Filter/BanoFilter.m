//
//  BanoFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/13/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "BanoFilter.h"
#import "ToneCurves.h"

NSString* const kBanoFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor1 = vec4(255.0/255.0,124.0/255.0,0.0/255.0,1.0);
 const vec4 fillColor2 = vec4(41.0/255.0,10.0/255.0,89.0/255.0,1.0);
 
 const vec3 minLevel = vec3(25.0 / 255.0,25.0 / 255.0,0.0);
 const vec3 gammaLevel = vec3(1.0,1.0,1.0);
 const vec3 maxLevel = vec3(255.0 / 255.0,255.0 / 255.0,255.0 / 255.0);
 
 const vec3 inLevel = vec3(0.0,0.0,120.0 / 255.0);
 const vec3 outLevel = vec3(1.0,1.0,1.0);
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = mix(fillColor1,fillColor2,textureCoordinate.y);
     
     vec4 pass2 = mix(textureColor,blend_Multiple(textureColor,pass1),0.1);
     
     vec4 pass3 = fn_Levels(pass2,20.0 / 255.0,1.20,220.0 / 255.0,0.0,1.0);
     
     vec4 pass4 = fn_Brightness(pass3,0.025);
     
     vec4 pass5 = fn_Contrast(pass4,1.3);
     
     vec4 pass6 = fn_ToneCurve(pass5,toneCurveTexture);
     
     gl_FragColor = fn_Vignette(textureCoordinate,pass6,0.6,0.75);
 }
 );

@interface BanoFilter ()
{
    GLuint uToneCurveTexture;
}

@property (nonatomic,strong) ToneCurves* curves;

@end

@implementation BanoFilter

+ (NSString *)filterName
{
    return @"Bano";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kBanoFilterFragShader];
    if (self)
    {
        uToneCurveTexture = [filterProgram uniformIndex:@"toneCurveTexture"];
        
        self.curves = [ToneCurves curves];
        self.curves.RgbCompositeControlPoints = @[CPoint(3, 20),CPoint(61, 61)];
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
