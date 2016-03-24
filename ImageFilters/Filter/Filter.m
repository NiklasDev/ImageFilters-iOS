//
//  Filter.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/9/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "Filter.h"
#import "GLSLFunction.h"

@implementation Filter
{
    GLuint uImageWidthFactor;
    GLuint uImageHeightFactor;
    BOOL useSizeFactor;
}

+ (NSString*)filterName
{
    return NSStringFromClass([self class]);
}

- (NSString*)filterName
{
    return [[self class] filterName];
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:[kGLSLFunction stringByAppendingString:fragmentShaderString]];
    if (self)
    {
        uImageWidthFactor = [filterProgram uniformIndex:@"imageWidthFactor"];
        uImageHeightFactor = [filterProgram uniformIndex:@"imageHeightFactor"];
        
        if (uImageWidthFactor < 20 && uImageHeightFactor < 20)
        {
            useSizeFactor = YES;
        }
    }
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (useSizeFactor)
    {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext setActiveShaderProgram:filterProgram];
            
            if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
            {
                glUniform1f(uImageWidthFactor, 1.0 / filterFrameSize.height);
                glUniform1f(uImageHeightFactor, 1.0 / filterFrameSize.width);
            }
            else
            {
                glUniform1f(uImageWidthFactor, 1.0 / filterFrameSize.width);
                glUniform1f(uImageHeightFactor, 1.0 / filterFrameSize.height);
            }
        });
    }
}

- (NSArray*)uniformSelectors
{
    return nil;
}

@end
