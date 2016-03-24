//
//  ImageFilters.m
//  ImageFilters
//
//  Created by Niklas Ahola on 9/30/13.
//  Copyright (c) 2013 Niklas Ahola. All rights reserved.
//

#import "ImageFilters.h"
#import "GPUImage.h"
#import "Filter.h"
#import "ProFilter.h"
#import "VintFilter.h"
#import "ByrdFilter.h"
#import "MissEtikateFilter.h"

@interface ImageFilters()   {
    UIImage *blendedImage;
    
    GPUImageFilter* _filter;
    GPUImagePicture* _picture;
}

@end

@implementation ImageFilters

- (id) init {
    self = [super init];
    if (self)   {
        
    }
    return self;
}
- (UIImage*) filterImage: (UIImage*) image atIndex: (int) index {
    
    switch (index) {
        case 1:
            return [self createFilterCali:image];
        case 2:
            return [self createFilterVint:image];
        case 3:
            return [self createFilterMate:image];
        case 4:
            return [self createFilterTurt:image];
        case 5:
            return [self createFilterLinc:image];
        case 6:
            return [self createFilterLair:image];
        case 7:
            return [self createFilterBeegee:image];
        case 8:
            return [self createFilterRusy:image];
        case 9:
            return [self createFilterDigi:image];
        case 10:
            return [self createFilterBano:image];
        case 11:
            return [self createFilterWatts:image];
        case 12:
            return [self createFilterWake:image];
        case 13:
            return [self createFilterLuca:image];
        case 14:
            return [self createFilterBrite:image];
        case 15:
            return [self createFilterBery:image];
        case 16:
            return [self createFilterLeon:image];
        case 17:
            return [self createFilterPelle:image];
        case 18:
            return [self createFilterSunn:image];
        default:
            break;
    }
    //natural
    return image;
}

- (UIImage*) applyFilterWithName:(NSString*)name withImage:(UIImage*) image {
    Class myClass = NSClassFromString(name);
    _filter = [[myClass alloc] init];
    [_picture removeAllTargets];
    [_filter prepareForImageCapture];
    
    _picture = [[GPUImagePicture alloc] initWithImage:image];
    [_picture addTarget:_filter];
    [_picture processImage];
    return [_filter imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
}

// 1- Cali
- (UIImage*) createFilterCali:(UIImage*) image  {
    return [self applyFilterWithName:@"ProFilter" withImage:image];
}
// 2- Vint
- (UIImage*) createFilterVint:(UIImage*) image  {
    return [self applyFilterWithName:@"VintFilter" withImage:image];
}
// 3- Mate
- (UIImage*) createFilterMate:(UIImage*) image  {
    return [self applyFilterWithName:@"ByrdFilter" withImage:image];
}
// 4- Turt
- (UIImage*) createFilterTurt: (UIImage*) image  {
    ////                ( HDR / Turt )
    
    
    GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:NO];
    
    //pass1 Overlay -> texture1
    GPUImagePicture *pass1Texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:NO];
    //Create Blend
    GPUImageOverlayBlendFilter *overlay = [[GPUImageOverlayBlendFilter alloc] init];
    
    //Create Filters
    GPUImageGrayscaleFilter *grayscale = [[GPUImageGrayscaleFilter alloc] init];
    GPUImageGaussianBlurFilter *gaussian = [GPUImageGaussianBlurFilter new];
    GPUImageExposureFilter *exposure = [GPUImageExposureFilter new];
    
    //Filters Settings
    exposure.exposure = 1.1; //original .85
    gaussian.blurSize = 4.0f; //rem by larry original = 10
    
    //Process First Texture
    [inputPicture addTarget:overlay];
    [pass1Texture addTarget:grayscale];
    [grayscale addTarget:overlay];
    [pass1Texture processImage];
    
    
    //pass2 Divide -> texture2
    GPUImagePicture *pass2Texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:NO];
    
    //Create New Blend
    GPUImageDivideBlendFilter *divide = [[GPUImageDivideBlendFilter alloc] init];
    
    //Process Second Texture
    [pass2Texture addTarget:grayscale];
    [grayscale addTarget:gaussian];
    [gaussian addTarget:exposure];
    [pass2Texture processImage];
    
    [overlay addTarget:divide];
    [exposure addTarget:divide];
    [pass2Texture processImage];
    
    //process final layers on picture
    [inputPicture processImage];
    
    //Add Processed Image to UIImage
    UIImage *outputImage = [divide imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return outputImage;
    
}

//5 - Linc
- (UIImage*) createFilterLinc: (UIImage*) image {
    return [self applyFilterWithName:@"MissEtikateFilter" withImage:image];
}

//6 - Lair
- (UIImage*) createFilterLair: (UIImage*) image {
    //Create Curve Filter
    GPUImageToneCurveFilter * curve = [[GPUImageToneCurveFilter alloc] initWithACV:@"CrossProcess"];
    GPUImageExposureFilter * exposure = [GPUImageExposureFilter new];
    
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    
    //Configure Filter
    exposure.exposure = 0.575;
    
    //Process Image
    [pic1 addTarget:exposure];
    [exposure addTarget:curve];
    [pic1 processImage];
    
    //Assign Output to UIImage
    blendedImage = [curve imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    
    return blendedImage;
}

//7 - Beegee
- (UIImage*) createFilterBeegee: (UIImage*) image  {
    ////                ( Old / Mantle )
    
    
    //Image Blending
    GPUImageMultiplyBlendFilter *multyplyBlend = [GPUImageMultiplyBlendFilter new];
    
    //Image Adjustments
    GPUImageGrayscaleFilter *grayscale = [GPUImageGrayscaleFilter new];
    GPUImageExposureFilter *exposer = [GPUImageExposureFilter new];
    GPUImageContrastFilter *contrast = [GPUImageContrastFilter new];
    GPUImageGammaFilter *gamma = [GPUImageGammaFilter new];
    GPUImageVignetteFilter * vignetta = [[GPUImageVignetteFilter alloc]init];
    
    //Adjustments Settings
    [vignetta setVignetteEnd:0.70];
    exposer.exposure = 0.90f;
    gamma.gamma = 2.0f;
    
    //contrast.contrast = 1.5;
    UIImage *im2 = [UIImage imageNamed:@"680.jpg"];
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:im2];
    
    
    //Process Texture 1
    [pic1 addTarget:grayscale];
    [grayscale addTarget:exposer];
    [exposer addTarget:gamma];
    [gamma addTarget:contrast];
    [contrast addTarget:multyplyBlend];
    [pic1 processImage];
    
    //Process Picture
    [pic2 addTarget:multyplyBlend];
    [multyplyBlend addTarget:vignetta];
    [pic2 processImage];
    
    
    
    //Assign Filtered Picture to UIImage View
    blendedImage = [vignetta imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return blendedImage;
}

//8 - Rusy
- (UIImage*) createFilterRusy: (UIImage*) image  {
    ////                Rusy
    
    
    //Create Blend Filters
    GPUImageOverlayBlendFilter *overlay = [GPUImageOverlayBlendFilter new];
    
    //Create Adjustments Filters
    GPUImageGrayscaleFilter * grayscale = [GPUImageGrayscaleFilter new];
    GPUImageContrastFilter * contrast = [GPUImageContrastFilter new];
    
    //Source Image and Texture
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"rusy.jpg"]];
    
    //Adjustment Filters Settings
    contrast.contrast = 1.25;
    
    //Picture Process
    [pic1 addTarget:grayscale];
    [grayscale addTarget:contrast];
    [contrast addTarget:overlay];
    [pic1 processImage];
    
    //Add Processed Image to Blend
    [pic2 addTarget:overlay];
    [pic2 processImage];
    
    //Assign Processed Image to UIImave
    blendedImage = [overlay imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return blendedImage;
}


//9 - Digi
- (UIImage*) createFilterDigi: (UIImage*) image  {
    return [self applyFilterWithName:@"DigiFilter" withImage:image];
}

//10 - Digi
- (UIImage*) createFilterBano: (UIImage*) image  {
    return [self applyFilterWithName:@"BanoFilter" withImage:image];
}

//11 - Watts
- (UIImage*) createFilterWatts: (UIImage*) image  {
    return [self applyFilterWithName:@"WattsFilter" withImage:image];
}

//12 - Watts
- (UIImage*) createFilterWake: (UIImage*) image  {
    return [self applyFilterWithName:@"WakeFilter" withImage:image];
}

//13 - Luca
- (UIImage*) createFilterLuca: (UIImage*) image  {
    return [self applyFilterWithName:@"AmatorkaFilter" withImage:image];
}

//14 - Brite
- (UIImage*) createFilterBrite: (UIImage*) image  {
    return [self applyFilterWithName:@"BriteFilter" withImage:image];
}

//15 - Bery
- (UIImage*) createFilterBery: (UIImage*) image  {
    return [self applyFilterWithName:@"BeryFilter" withImage:image];
}

//16 - Leon
- (UIImage*) createFilterLeon: (UIImage*) image  {
    return [self applyFilterWithName:@"ThreeHundredFilter" withImage:image];
}
//17 - Pelle
- (UIImage*) createFilterPelle: (UIImage*) image  {
    return [self applyFilterWithName:@"HDRBWFilter" withImage:image];
}

//18 - Sunn - exception - for sun
- (UIImage*) createFilterSunn: (UIImage*) image  {
    return [self applyFilterWithName:@"SunnFilter" withImage:image];
}


//old code
- (UIImage*) createFilterToon: (UIImage*) image  {
    //Create Blends
    GPUImageDarkenBlendFilter *darken = [GPUImageDarkenBlendFilter new];
    
    //Create Filters ( Adjustment layers )
    GPUImageGaussianBlurFilter *gassian = [GPUImageGaussianBlurFilter new];
    GPUImageSharpenFilter *sharpen = [GPUImageSharpenFilter new];
    GPUImageLuminanceThresholdFilter *edges = [GPUImageLuminanceThresholdFilter new];
    
    //Create Pictures
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic3 = [[GPUImagePicture alloc] initWithImage:image];
    
    //Filters ( Adjustmnets ) Settings
    gassian.blurSize = 1.75f;
    edges.threshold = 0.40f;
    [pic2 addTarget:darken];
    
    //Process Image
    [pic1 addTarget:gassian];
    [gassian addTarget:sharpen];
    [sharpen addTarget:darken];
    [pic1 processImage];
    
    //Create new blend
    GPUImageDarkenBlendFilter *darken2 = [GPUImageDarkenBlendFilter new];
    
    //Process Image
    [pic3 addTarget:edges];
    [pic3 processImage];
    
    [darken addTarget:darken2];
    [edges addTarget:darken2];
    [pic3 processImage];
    
    [pic2 processImage];
    
    //Add Processed Image to UIImage
    blendedImage = [darken2 imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return blendedImage;
    
}


//done




//other
- (UIImage*) createFilterLightToon: (UIImage*) image  {
    ////                Toon Light
    
    //Create Blend
    GPUImageDarkenBlendFilter *darken = [GPUImageDarkenBlendFilter new];
    
    //Create Filters
    GPUImageGaussianBlurFilter *gassian = [GPUImageGaussianBlurFilter new];
    GPUImageSharpenFilter *sharpen = [GPUImageSharpenFilter new];
    GPUImageLuminanceThresholdFilter *edges = [GPUImageLuminanceThresholdFilter new];
    
    //Create Pictures
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:image];
    
    //Filters ( Adjustments ) Settings
    gassian.blurSize = 1.75f;
    edges.threshold = 0.05f;
    [pic2 addTarget:darken];
    
    [pic1 addTarget:gassian];
    [gassian addTarget:sharpen];
    [sharpen addTarget:darken];
    [pic1 processImage];
    
    GPUImagePicture *pic3 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageDarkenBlendFilter *darken2 = [GPUImageDarkenBlendFilter new];
    
    //Process Image
    [pic3 addTarget:edges];
    [pic3 processImage];
    
    [darken addTarget:darken2];
    [edges addTarget:darken2];
    [pic3 processImage];
    
    [pic2 processImage];
    
    //Add Processed Picture to UIImage
    blendedImage = [darken2 imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return blendedImage;

}
- (UIImage*) createFilterLastToon: (UIImage*) image  {
    ////                Last Toon Filter
    
    
    //GPUImageChromaKeyFilter *chroma = [GPUImageChromaKeyFilter new];
    GPUImageSmoothToonFilter *toon = [GPUImageSmoothToonFilter new];
    GPUImageGaussianBlurFilter *gaussian = [GPUImageGaussianBlurFilter new];
    
    GPUImageSketchFilter *sketch = [GPUImageSketchFilter new];
    GPUImageMultiplyBlendFilter *normal = [GPUImageMultiplyBlendFilter new];
    
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:image];
    
    toon.threshold = 1;
    toon.quantizationLevels = 8;
    
    gaussian.blurSize = 0.0f;
    //gaussian.blurSize = 1.0f;
    sketch.edgeStrength = 0.7;
    sketch.texelWidth = 0.001;
    sketch.texelHeight = 0.001;
    
    [pic1 addTarget:toon];
    [toon addTarget:normal];
    [pic1 processImage];
    
    [pic2 addTarget:gaussian];
    [gaussian addTarget:sketch];
    [sketch addTarget:normal];
    [pic2 processImage];
    
    
    [pic1 processImage];
    blendedImage = [normal imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return blendedImage;

}
- (UIImage*) createFilterOilPainting: (UIImage*) image  {
    ////                Oil-Painting
    
    //Create Blend
    GPUImageOverlayBlendFilter *overlay = [GPUImageOverlayBlendFilter new];
    
    //Create Filters ( Adjustment layers )
    GPUImageKuwaharaRadius3Filter *oilPaint = [GPUImageKuwaharaRadius3Filter new];
    GPUImageToonFilter *toon = [GPUImageToonFilter new];
    GPUImageBrightnessFilter *brightness = [GPUImageBrightnessFilter new];
    
    //Create Pictures
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:image];
    
    //Filters ( Adjustments ) Settings
    [toon setThreshold:0.9f];
    [toon setTexelHeight:0.001f];
    [toon setTexelWidth:0.001f];
    [toon setQuantizationLevels:8.0f];
    [brightness setBrightness:0.25];
    
    
    //Image Processing
    [pic1 addTarget:oilPaint];
    [oilPaint addTarget:brightness];
    [brightness addTarget:overlay];
    [pic1 processImage];
    
    [pic2 addTarget:toon];
    [toon addTarget:overlay];
    [pic2 processImage];
    
    //Add Processed Image to UIImage

    blendedImage = [overlay imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    return blendedImage;
}

@end
