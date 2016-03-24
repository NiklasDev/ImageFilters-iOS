//
//  ByrdFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/12/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "ByrdFilter.h"

NSString* const kByrdFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 const vec4 fillColor = vec4(251.0/255.0,227.0/255.0,215.0/255.0,1.0);
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture,textureCoordinate);
     
     vec4 pass1 = fn_Vignette(textureCoordinate,color,0.3,1.0);
     
     vec4 pass2 = fn_Levels(pass1,0.0,0.92,235.0 / 255.0,0.0,1.0);
     
     vec4 pass3 = fn_HSB(pass2,0.0,-0.05,0.0);
     
     vec4 pass4 = fn_Brightness(pass3,0.05);
     
     vec4 pass5 = fn_Contrast(pass4,1.2);
     
     vec4 pass6 = fn_Levels(pass5,0.0,1.2,1.0,0.0,1.0);
     
     vec4 pass7 = fn_Desaturate(pass6,0.32);
     
     vec4 pass8 = blend_Multiple(pass7,fillColor);
     
     gl_FragColor = pass8;
 }
 
 );

@implementation ByrdFilter

+ (NSString *)filterName
{
    return @"Byrd";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kByrdFilterFragShader];
    if (self)
    {
        
    }
    return self;
}

@end
