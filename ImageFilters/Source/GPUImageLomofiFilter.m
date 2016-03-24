//
//  GPUImageLomofiFilter.m
//  GPUImage
//
//  Created by Mohammed on 9/24/13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageLomofiFilter.h"

NSString *const kIFLomofiShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 vec4 ApplyVividLight( vec4 over, vec4 under, float fill )
{
    vec3 NeutralColor = vec3(.5,.5,.5);
    over.rgb = mix( NeutralColor, over.rgb, fill );
    
    over.rgb -= 0.5;
    over.rgb *= 2.0;
    
    vec4 ret;
    ret.rgb = under.rgb;
    ret.rgb += min(over.rgb, 0.0);
    ret.rgb /= max(1.0-abs(over.rgb), 0.000001);
    ret.rgb *= under.a;
    ret = clamp( ret, 0.0, 1.0 );
    ret.rgb *= over.a;
    
    ret.a = over.a * under.a;
    
    return ret;
}
 
 void main(void)
{
    vec4 under = texture2D( inputImageTexture, textureCoordinate );
    vec4 over = texture2D( inputImageTexture2, textureCoordinate2 );
    
    vec4 ret = ApplyVividLight( over, under, gl_Color.a );
    
    ret.rgb += (1.0 - over.a) * under.rgb * under.a;
    ret.a += (1.0 - over.a) * under.a;
    
    over.a *= gl_Color.a;
    ret.rgb += (1.0 - under.a) * over.rgb * over.a;
    ret.a += (1.0 - under.a) * over.a;
    
    ret.rgb /= ret.a;
    
    gl_FragColor = ret;
    return;
}
 );

@implementation GPUImageLomofiFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kIFLomofiShaderString]))
    {
		return nil;
    }
    
    return self;
}

@end
