//
//  EditPhotoService.m
//  Flipframe
//
//  Created by Niklas Ahola on 8/23/13.
//  Copyright (c) 2013 Niklas Ahola. All rights reserved.
//

#import "EditPhotoService.h"

@implementation EditPhotoService
- (id) init {
    self = [super init];
    if (self != nil)    {
        //brightness
        _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        _brightnessFilter.brightness = DEFAULT_SUN_BRIGHTNESS;
        
        //contrast
        _contrastFilter = [[GPUImageContrastFilter alloc] init];
        _contrastFilter.contrast = DEFAULT_SUN_CONTRAST;
        
        _sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        _sharpenFilter.sharpness = DEFAULT_SUN_SHARPEN;
        
        //blur
        _blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
        
        //filter service
        _filterService = [[ImageFilters alloc] init];
        
        //ios 7 filter service
        _imageFilterIOS7 = [[ImageFilterIOS7 alloc] init];
    }
    return self;
}
-(UIImage*) brightnessAndContrast:(UIImage*) image  {
    if (![self checkImageValid:image])   {
        return image;
    }
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:_brightnessFilter];
    [_brightnessFilter addTarget:_contrastFilter];
    [_contrastFilter addTarget:_sharpenFilter];
    [pic processImage];
    
    UIImage *curImage = [_sharpenFilter imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return curImage;
    
}

//with centerPoint from (0,0) to (1,1)
-(UIImage*) blurRadial:(UIImage*) image withPoint:(CGPoint) centerPoint  withSize:(CGFloat) blurSize withCircleRadius:(CGFloat) circleRadus {
    if (![self checkImageValid:image])   {
        return image;
    }
    
    _blurFilter.blurSize = 1.5;
    _blurFilter.excludeCirclePoint = centerPoint;
    _blurFilter.excludeBlurSize = blurSize;
    _blurFilter.excludeCircleRadius = circleRadus;
    
    return [_blurFilter imageByFilteringImage:image];
}
-(UIImage*) blurLinear:(UIImage*) image withPoint:(CGPoint) centerPoint  withHeight:(CGFloat) height    {
    if (![self checkImageValid:image])   {
        return image;
    }
    
    _tiltShiftFilter = [[GPUImageTiltShiftFilter alloc] init];
    _tiltShiftFilter.blurSize = 1.5;
    
    float top = MAX(0, centerPoint.y - (height / 2));
    float bot = MAX(top, MIN(1, centerPoint.y + (height / 2)));
    //NSLog(@"top -bot: %f - %f ", top, bot);
    _tiltShiftFilter.topFocusLevel = top;
    _tiltShiftFilter.bottomFocusLevel = bot;
    _tiltShiftFilter.focusFallOffRate = 0.2;
    
    return [_tiltShiftFilter imageByFilteringImage:image];
}

//filter image
- (UIImage*) filterImage: (UIImage*) image withIndex:(int) index isIOS7:(BOOL) isIOS7    {
    if (![self checkImageValid:image])   {
        return image;
    }
    if (isIOS7) {
        if (index == 6) //lair
        {
            return [_imageFilterIOS7 filterImage:image atIndex:index];
        }
    }
    return [_filterService filterImage:image atIndex:index];
}
- (BOOL) checkImageValid:(UIImage*) image   {
    if (image)  {
        if (image.size.width > 0 && image.size.height > 0)  {
            return YES;
        }
    }
    return NO;
}
@end
