//
//  Filter.h
//  FiltersApp
//
//  Created by Niklas Ahola on 2/9/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "GPUImageFilter.h"

#define LOG_UNIFORM_VALUE(x) NSLog(@"%s value = %f, %s = %f",__func__,value,#x,x)
#define UNIFORM_SEL(sel,min,max) @{@"sel":NSStringFromSelector(sel),@"min":@(min),@"max":@(max)}

@interface Filter : GPUImageFilter

+ (NSString*)filterName;
- (NSString*)filterName;

- (NSArray*)uniformSelectors;

@end
