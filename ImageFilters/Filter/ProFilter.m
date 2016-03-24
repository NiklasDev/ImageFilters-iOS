//
//  ProFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/13/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "ProFilter.h"
#import "ToneCurves.h"

NSString* const kProFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = fn_ToneCurve(color,toneCurveTexture);
 }
 );

@interface ProFilter ()
{
    GLuint uToneCurveTexture;
}

@property (nonatomic,strong) ToneCurves* curves;

@end

@implementation ProFilter

+ (NSString *)filterName
{
    return @"Pro";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kProFilterFragShader];
    if (self)
    {
        uToneCurveTexture = [filterProgram uniformIndex:@"toneCurveTexture"];
        
        self.curves = [ToneCurves curves];
        self.curves.RgbCompositeControlPoints = @[CPointSwap(45, 62),CPointSwap(128, 129),CPointSwap(204, 187)];
        self.curves.RedControlPoints = @[CPointSwap(21, 54),CPointSwap(86, 105),CPointSwap(144, 148),CPointSwap(209, 201)];
        self.curves.GreenControlPoints = @[CPointSwap(61, 87),CPointSwap(231, 231)];
        self.curves.BlueControlPoints = @[CPointSwap(25, 0),CPointSwap(82, 76),CPointSwap(149, 163),CPointSwap(181, 255)];
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
