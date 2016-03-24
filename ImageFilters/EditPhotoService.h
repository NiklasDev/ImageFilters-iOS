//
//  EditPhotoService.h
//  Flipframe
//
//  Created by Niklas Ahola on 8/23/13.
//  Copyright (c) 2013 Niklas Ahola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "ImageFilters.h"
#import "ImageFilterIOS7.h"
#import "GPUImageTiltShiftFilter.h"

@interface EditPhotoService : NSObject  {
    GPUImageBrightnessFilter *_brightnessFilter;
    GPUImageContrastFilter *_contrastFilter;
    GPUImageSharpenFilter *_sharpenFilter;
    
    
    GPUImageGaussianSelectiveBlurFilter *_blurFilter;
    GPUImageGaussianBlurFilter *_blurLinear;
    GPUImageTiltShiftFilter *_tiltShiftFilter;
    
    
    ImageFilters *_filterService;
    ImageFilterIOS7 *_imageFilterIOS7;
}

//brightness and contrast
-(UIImage*) brightnessAndContrast:(UIImage*) image;

//with radial centerPoint from (0,0) to (1,1)
-(UIImage*) blurRadial:(UIImage*) image withPoint:(CGPoint) centerPoint  withSize:(CGFloat) blurSize withCircleRadius:(CGFloat) circleRadus;

//with linear centerPoint from (0,0) to (1,1)
-(UIImage*) blurLinear:(UIImage*) image withPoint:(CGPoint) centerPoint  withHeight:(CGFloat) height;

//apply filter
- (UIImage*) filterImage: (UIImage*) image withIndex:(int) index isIOS7:(BOOL) isIOS7;
@end
