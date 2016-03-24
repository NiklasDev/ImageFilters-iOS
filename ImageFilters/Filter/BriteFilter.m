//
//  BriteFilter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/11/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "BriteFilter.h"

NSString* const kBriteFilterFragShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 const vec4 fillColor = vec4(192.0 / 255.0,109.0 / 255.0,213.0 / 255.0,1.0);
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 pass1 = fn_Levels(textureColor,10.0 / 255.0,1.0,190.0 / 255.0,0.0,1.0);
     
     vec4 pass2 = fn_ShadowAndHighlights(textureColor,0.37,0.40);
     
     vec4 pass3 = mix(pass1, pass2, 0.5);
     
     vec4 pass4 = mix(pass3,blend_HardLight(pass3,textureColor),0.4);
     
     vec4 pass5 = blend_ColorDodge(pass4,fillColor);
     
     gl_FragColor = mix(pass4,pass5,0.25);
 }
);

@implementation BriteFilter

+ (NSString *)filterName
{
    return @"Brite";
}

- (id)init
{
    self = [super initWithFragmentShaderFromString:kBriteFilterFragShader];
    if (self)
    {
        
    }
    return self;
}

@end
