//
//  BeryFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/17/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "BeryFilter.h"

NSString* const kBeryFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_ShadowAndHighlights(textureColor,0.12,0.8);
     
     vec4 pass2 = fn_Levels(pass1,5.0 / 255.0,1.0,245.0 / 255.0,0.0,1.0);
     
     vec4 pass3 = fn_BrightnessAndContrast(pass2,0.03,1.15);
     
     vec4 pass4 = fn_HSB(pass3,0.0,0.053,0.0);
     
     gl_FragColor = pass4;
 }
 );

@implementation BeryFilter

+ (NSString *)filterName
{
    return @"Bery";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kBeryFilterFragShader];
    if (self)
    {
        
    }
    return self;
}

@end
