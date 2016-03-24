//
//  ImageFilters.h
//  ImageFilters
//
//  Created by Niklas Ahola on 9/30/13.
//  Copyright (c) 2013 Niklas Ahola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ImageFilters : NSObject
- (UIImage*) filterImage: (UIImage*) image atIndex: (int) index;
@end
