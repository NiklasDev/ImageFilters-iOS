//
//  SunnFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/14/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "SunnFilter.h"

NSString* const kSunnFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const vec4 fillColor1 = vec4(255.0/255.0,124.0/255.0,0.0/255.0,1.0);
 const vec4 fillColor2 = vec4(41.0/255.0,10.0/255.0,89.0/255.0,1.0);
 
 vec4 fn_Exposure(vec4 color, float exposure)
 {
     return vec4(color.rgb * pow(2.0, exposure), color.w);
 }
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_ShadowAndHighlights(textureColor,0.4,1.0);
     
     vec4 pass2 = mix(fillColor1,fillColor2,textureCoordinate.y);
     
     vec4 pass3 = mix(pass1,blend_Multiple(pass1,pass2),0.1);
     
     vec4 pass4 = fn_Brightness(pass3,0.1);
     
     vec4 pass5 = fn_Contrast(pass4,1.2);
     
     gl_FragColor = pass5;
 }
 );

@implementation SunnFilter

+ (NSString *)filterName
{
    return @"Sunn";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kSunnFilterFragShader];
    if (self)
    {
        
    }
    return self;
}

@end
