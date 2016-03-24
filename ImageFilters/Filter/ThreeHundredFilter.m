//
//  ThreeHundredFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/14/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "ThreeHundredFilter.h"

NSString* const kThreeHundredFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor1 = vec4(108.0/255.0,59.0/255.0,47.0/255.0,1.0);
 const vec4 fillColor2 = vec4(231.0/255.0,127.0/255.0,65.0/255.0,1.0);
 
 vec4 fn_Exposure(vec4 color, float exposure)
 {
     return vec4(color.rgb * pow(2.0, exposure), color.w);
 }
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_Desaturate(textureColor,1.0);
     
     vec4 pass2 = fn_ShadowAndHighlights(pass1,0.48,1.0);
     
     vec4 pass3 = mix(pass2,blend_Overlay(pass2,fillColor1),0.9);
     
     vec4 pass4 = mix(pass3,blend_Lighten(pass3,fillColor2),0.3);
     
     vec4 pass5 = blend_Overlay(pass4,pass1);
     
     gl_FragColor = pass5;
 }
 );

@implementation ThreeHundredFilter

+ (NSString *)filterName
{
    return @"300";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kThreeHundredFilterFragShader];
    if (self)
    {
        
    }
    return self;
}

@end
