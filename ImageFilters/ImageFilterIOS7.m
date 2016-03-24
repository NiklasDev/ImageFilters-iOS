//
//  ImageFilterIOS7.m
//  ImageFilters
//
//  Created by Niklas Ahola on 11/19/13.
//  Copyright (c) 2013 Niklas Ahola. All rights reserved.
//

#import "ImageFilterIOS7.h"

@implementation ImageFilterIOS7
- (UIImage*) filterImage: (UIImage*) image atIndex: (int) index
{
    switch (index) {
        case 6:
            return [self createFilterFade:image];
            break;
        default:
            break;
    }
    return image;
}

//internal method

//index  == 1, name Lair = Fade
- (UIImage*) createFilterFade: (UIImage*) image {
    NSString* type = @"CIPhotoEffectFade";
    return [self createIOS7FilterWithType:type image:image];
}

//index  == 6, name Mate = Instant
- (UIImage*) createFilterInstant: (UIImage*) image {
    NSString* type = @"CIPhotoEffectInstant";
    return [self createIOS7FilterWithType:type image:image];
}

//index  == 5, name Linc = Chrome
- (UIImage*) createFilterChrome: (UIImage*) image {
    NSString* type = @"CIPhotoEffectChrome";
    return [self createIOS7FilterWithType:type image:image];
}

//index  == 3, name Cali = Transfer
- (UIImage*) createFilterTransfer: (UIImage*) image {
    NSString* type = @"CIPhotoEffectTransfer";
    return [self createIOS7FilterWithType:type image:image];
}
- (UIImage*) createIOS7FilterWithType:(NSString*)type image:(UIImage*) image    {
    @autoreleasepool {
        CIImage *ciImage = [[CIImage alloc] initWithImage:image];
        
        CIFilter *filter = [CIFilter filterWithName:type
                                      keysAndValues:kCIInputImageKey, ciImage, nil];
        [filter setDefaults];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = [filter outputImage];
        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        UIImage *outImage = [UIImage imageWithCGImage:cgImage scale:1 orientation:image.imageOrientation];
        
        context = nil;
        filter = nil;
        ciImage = nil;
        outputImage = nil;
        CGImageRelease(cgImage);
        cgImage = nil;
        
        return outImage;
    }
}

@end
