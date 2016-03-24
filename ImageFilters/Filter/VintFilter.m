//
//  VintFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/13/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "VintFilter.h"
#import "ToneCurves.h"

NSString* const kVintFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture1;
 uniform sampler2D toneCurveTexture2;
 uniform sampler2D toneCurveTexture3;
 uniform sampler2D toneCurveTexture4;
 
 const vec4 fillColor = vec4(247.0/255.0,210.0/255.0,190.0/255.0,1.0);
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_Vignette(textureCoordinate,color,0.45,0.85);
     
     vec4 pass2 = blend_Multiple(pass1,fillColor);
     
     vec4 pass3 = fn_Levels(pass2,30.0 / 255.0,1.0,1.0,0.0,1.0);
     
     vec4 pass4 = fn_ToneCurve(pass3,toneCurveTexture1);
     
     vec4 pass5 = fn_Levels(pass4,0.0,1.36,236.0 / 255.0,0.0,1.0);
     
     vec4 pass6 = fn_BrightnessAndContrast(pass5,0.04,1.2);

     vec4 pass7 = fn_ToneCurve(pass6,toneCurveTexture2);
     
     vec4 pass8 = fn_BrightnessAndContrast(pass7,-0.05,1.14);
     
     vec4 pass9 = fn_ToneCurve(pass8,toneCurveTexture3);
     
     vec4 pass10 = fn_ToneCurve(pass8,toneCurveTexture4);
     
     gl_FragColor = pass10;
 }
 );

@interface VintFilter ()
{
    GLuint uToneCurveTexture1;
    GLuint uToneCurveTexture2;
    GLuint uToneCurveTexture3;
    GLuint uToneCurveTexture4;
}

@property (nonatomic,strong) ToneCurves* curves1;
@property (nonatomic,strong) ToneCurves* curves2;
@property (nonatomic,strong) ToneCurves* curves3;
@property (nonatomic,strong) ToneCurves* curves4;

@end

@implementation VintFilter

+ (NSString *)filterName
{
    return @"Vint";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kVintFilterFragShader];
    if (self)
    {
        uToneCurveTexture1 = [filterProgram uniformIndex:@"toneCurveTexture1"];
        uToneCurveTexture2 = [filterProgram uniformIndex:@"toneCurveTexture2"];
        uToneCurveTexture3 = [filterProgram uniformIndex:@"toneCurveTexture3"];
        uToneCurveTexture4 = [filterProgram uniformIndex:@"toneCurveTexture4"];
        
        self.curves1 = [ToneCurves curvesWithACVFileName:@"Vint1"];
        self.curves2 = [ToneCurves curvesWithACVFileName:@"Vint2"];
        self.curves3 = [ToneCurves curvesWithACVFileName:@"Vint3"];
        self.curves4 = [ToneCurves curvesWithACVFileName:@"Vint4"];
    }
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture
{
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, self.curves1.textureId);
    [self setInteger:4 forUniform:uToneCurveTexture1 program:filterProgram];
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, self.curves2.textureId);
    [self setInteger:5 forUniform:uToneCurveTexture2 program:filterProgram];
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, self.curves3.textureId);
    [self setInteger:6 forUniform:uToneCurveTexture3 program:filterProgram];
    
    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, self.curves4.textureId);
    [self setInteger:7 forUniform:uToneCurveTexture4 program:filterProgram];
    
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates sourceTexture:sourceTexture];
}

@end
