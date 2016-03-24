//
//  ImageFilterIOS7.h
//  ImageFilters
//
//  Created by Niklas Ahola on 11/19/13.
//  Copyright (c) 2013 Niklas Ahola. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFilterIOS7 : NSObject
- (UIImage*) filterImage: (UIImage*) image atIndex: (int) index;
@end
