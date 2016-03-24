//
//  ToneCurves.m
//  FiltersApp
//
//  Created by Niklas Ahola on 2/13/14.
//  Copyright (c) 2014 Niklas Ahola. All rights reserved.
//

#import "ToneCurves.h"
#import "GPUImage.h"

unsigned short _int16WithBytes(Byte* bytes)
{
    uint16_t result;
    memcpy(&result, bytes, sizeof(result));
    return CFSwapInt16BigToHost(result);
}

@interface ToneCurves ()
{
    GLuint textureId;
    GLubyte *toneCurveByteArray;
    
    NSArray *_redCurve, *_greenCurve, *_blueCurve, *_rgbCompositeCurve;
    
    short version;
    short totalCurves;
}

@end


@implementation ToneCurves
@synthesize textureId;

+ (instancetype)curves
{
    return [[self alloc] init];
}

+ (instancetype)curvesWithACVFileName:(NSString*)fileName
{
    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"acv"]];
    return [[self alloc] initWithACVFileData:data];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.RGBControlPoints = @[CPoint(0, 0),CPoint(255, 255)];
        self.RgbCompositeControlPoints = @[CPoint(0, 0),CPoint(255, 255)];
    }
    return self;
}

- (id)initWithACVFileData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        if (data.length == 0)
        {
            NSLog(@"failed to init ACVFile with data:%@", data);
            return self;
        }
        
        Byte* rawBytes = (Byte*) [data bytes];
        version        = _int16WithBytes(rawBytes);
        rawBytes+=2;
        
        totalCurves    = _int16WithBytes(rawBytes);
        rawBytes+=2;
        
        NSMutableArray *curves = [NSMutableArray new];
        
        float pointRate = (1.0 / 255);
        // The following is the data for each curve specified by count above
        for (NSInteger x = 0; x<totalCurves; x++)
        {
            unsigned short pointCount = _int16WithBytes(rawBytes);
            rawBytes+=2;
            
            NSMutableArray *points = [NSMutableArray new];
            // point count * 4
            // Curve points. Each curve point is a pair of short integers where
            // the first number is the output value (vertical coordinate on the
            // Curves dialog graph) and the second is the input value. All coordinates have range 0 to 255.
            for (NSInteger y = 0; y<pointCount; y++)
            {
                unsigned short y = _int16WithBytes(rawBytes);
                rawBytes+=2;
                unsigned short x = _int16WithBytes(rawBytes);
                rawBytes+=2;
                [points addObject:[NSValue valueWithCGSize:CGSizeMake(x * pointRate, y * pointRate)]];
            }
            [curves addObject:points];
        }
        
        _rgbCompositeCurve = [self getPreparedSplineCurve:[curves objectAtIndex:0]];
        _redCurve = [self getPreparedSplineCurve:[curves objectAtIndex:1]];
        _greenCurve = [self getPreparedSplineCurve:[curves objectAtIndex:2]];
        _blueCurve = [self getPreparedSplineCurve:[curves objectAtIndex:3]];
        
        [self updateToneCurveTexture];
    }
    return self;
}

- (void)dealloc
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (textureId)
        {
            glDeleteTextures(1, &textureId);
            textureId = 0;
        }
    });
    
    if (toneCurveByteArray)
    {
        free(toneCurveByteArray);
        toneCurveByteArray = NULL;
    }
}

#pragma mark -
#pragma mark Curve calculation

- (NSArray*)getPreparedSplineCurve:(NSArray*)points
{
    if (points && [points count] > 0)
    {
        // Sort the array.
        NSArray* sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            float x1 = [(NSValue *)a CGPointValue].x;
            float x2 = [(NSValue *)b CGPointValue].x;
            return x1 > x2;
        }];
        
        // Convert from (0, 1) to (0, 255).
        NSMutableArray* convertedPoints = [NSMutableArray arrayWithCapacity:[sortedPoints count]];
        for (int i=0; i<[points count]; i++)
        {
            CGPoint point = [[sortedPoints objectAtIndex:i] CGPointValue];
            
            point.x = point.x * 255;
            point.y = point.y * 255;
            
            [convertedPoints addObject:[NSValue valueWithCGPoint:point]];
        }
        
        
        NSMutableArray* splinePoints = [self splineCurve:convertedPoints];
        
        // If we have a first point like (0.3, 0) we'll be missing some points at the beginning
        // that should be 0.
        CGPoint firstSplinePoint = [[splinePoints objectAtIndex:0] CGPointValue];
        
        if (firstSplinePoint.x > 0)
        {
            for (int i=firstSplinePoint.x; i >= 0; i--)
            {
                CGPoint newCGPoint = CGPointMake(i, 0);
                [splinePoints insertObject:[NSValue valueWithCGPoint:newCGPoint] atIndex:0];
            }
        }
        
        // Insert points similarly at the end, if necessary.
        CGPoint lastSplinePoint = [[splinePoints lastObject] CGPointValue];
        
        if (lastSplinePoint.x < 255)
        {
            for (int i = lastSplinePoint.x + 1; i <= 255; i++)
            {
                CGPoint newCGPoint = CGPointMake(i, 255);
                [splinePoints addObject:[NSValue valueWithCGPoint:newCGPoint]];
            }
        }
        
        // Prepare the spline points.
        NSMutableArray* preparedSplinePoints = [NSMutableArray arrayWithCapacity:[splinePoints count]];
        for (int i=0; i<[splinePoints count]; i++)
        {
            CGPoint newPoint = [[splinePoints objectAtIndex:i] CGPointValue];
            CGPoint origPoint = CGPointMake(newPoint.x, newPoint.x);
            
            float distance = sqrt(pow((origPoint.x - newPoint.x), 2.0) + pow((origPoint.y - newPoint.y), 2.0));
            
            if (origPoint.y > newPoint.y)
            {
                distance = -distance;
            }
            
            [preparedSplinePoints addObject:[NSNumber numberWithFloat:distance]];
        }
        
        return preparedSplinePoints;
    }
    
    return nil;
}


- (NSMutableArray*)splineCurve:(NSArray*)points
{
    NSMutableArray* sdA = [self secondDerivative:points];
    
    // [points count] is equal to [sdA count]
    NSInteger n = [sdA count];
    if (n < 1)
    {
        return nil;
    }
    double sd[n];
    
    // From NSMutableArray to sd[n];
    for (int i=0; i<n; i++)
    {
        sd[i] = [[sdA objectAtIndex:i] doubleValue];
    }
    
    
    NSMutableArray*output = [NSMutableArray arrayWithCapacity:(n+1)];
    
    for(int i=0; i<n-1 ; i++)
    {
        CGPoint cur = [[points objectAtIndex:i] CGPointValue];
        CGPoint next = [[points objectAtIndex:(i+1)] CGPointValue];
        
        for(int x=cur.x;x<(int)next.x;x++)
        {
            double t = (double)(x-cur.x)/(next.x-cur.x);
            
            double a = 1-t;
            double b = t;
            double h = next.x-cur.x;
            
            double y= a*cur.y + b*next.y + (h*h/6)*( (a*a*a-a)*sd[i]+ (b*b*b-b)*sd[i+1] );
            
            if (y > 255.0)
            {
                y = 255.0;
            }
            else if (y < 0.0)
            {
                y = 0.0;
            }
            
            [output addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
    }
    
    // The above always misses the last point because the last point is the last next, so we approach but don't equal it.
    [output addObject:[points lastObject]];
    return output;
}

- (NSMutableArray*)secondDerivative:(NSArray*)points
{
    const NSInteger n = [points count];
    if ((n <= 0) || (n == 1))
    {
        return nil;
    }
    
    double matrix[n][3];
    double result[n];
    matrix[0][1]=1;
    // What about matrix[0][1] and matrix[0][0]? Assuming 0 for now (Brad L.)
    matrix[0][0]=0;
    matrix[0][2]=0;
    
    for(int i=1;i<n-1;i++)
    {
        CGPoint P1 = [[points objectAtIndex:(i-1)] CGPointValue];
        CGPoint P2 = [[points objectAtIndex:i] CGPointValue];
        CGPoint P3 = [[points objectAtIndex:(i+1)] CGPointValue];
        
        matrix[i][0]=(double)(P2.x-P1.x)/6;
        matrix[i][1]=(double)(P3.x-P1.x)/3;
        matrix[i][2]=(double)(P3.x-P2.x)/6;
        result[i]=(double)(P3.y-P2.y)/(P3.x-P2.x) - (double)(P2.y-P1.y)/(P2.x-P1.x);
    }
    
    // What about result[0] and result[n-1]? Assuming 0 for now (Brad L.)
    result[0] = 0;
    result[n-1] = 0;
	
    matrix[n-1][1]=1;
    // What about matrix[n-1][0] and matrix[n-1][2]? For now, assuming they are 0 (Brad L.)
    matrix[n-1][0]=0;
    matrix[n-1][2]=0;
    
  	// solving pass1 (up->down)
  	for(int i=1;i<n;i++)
    {
		double k = matrix[i][0]/matrix[i-1][1];
		matrix[i][1] -= k*matrix[i-1][2];
		matrix[i][0] = 0;
		result[i] -= k*result[i-1];
    }
	// solving pass2 (down->up)
	for(NSInteger i=n-2;i>=0;i--)
    {
		double k = matrix[i][2]/matrix[i+1][1];
		matrix[i][1] -= k*matrix[i+1][0];
		matrix[i][2] = 0;
		result[i] -= k*result[i+1];
	}
    
    double y2[n];
    for(int i=0;i<n;i++) y2[i]=result[i]/matrix[i][1];
    
    NSMutableArray* output = [NSMutableArray arrayWithCapacity:n];
    for (int i=0;i<n;i++)
    {
        [output addObject:[NSNumber numberWithDouble:y2[i]]];
    }
    
    return output;
}

- (void)updateToneCurveTexture
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        if (!textureId)
        {
            glActiveTexture(GL_TEXTURE3);
            glGenTextures(1, &textureId);
            glBindTexture(GL_TEXTURE_2D, textureId);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            toneCurveByteArray = calloc(256 * 4, sizeof(GLubyte));
        }
        else
        {
            glActiveTexture(GL_TEXTURE3);
            glBindTexture(GL_TEXTURE_2D, textureId);
        }
        
        if ( ([_redCurve count] >= 256) && ([_greenCurve count] >= 256) && ([_blueCurve count] >= 256) && ([_rgbCompositeCurve count] >= 256))
        {
            for (unsigned int currentCurveIndex = 0; currentCurveIndex < 256; currentCurveIndex++)
            {
                // BGRA for upload to texture
                GLubyte b = fmin(fmax(currentCurveIndex + [[_blueCurve objectAtIndex:currentCurveIndex] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4] = fmin(fmax(b + [[_rgbCompositeCurve objectAtIndex:b] floatValue], 0), 255);
                GLubyte g = fmin(fmax(currentCurveIndex + [[_greenCurve objectAtIndex:currentCurveIndex] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4 + 1] = fmin(fmax(g + [[_rgbCompositeCurve objectAtIndex:g] floatValue], 0), 255);
                GLubyte r = fmin(fmax(currentCurveIndex + [[_redCurve objectAtIndex:currentCurveIndex] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4 + 2] = fmin(fmax(r + [[_rgbCompositeCurve objectAtIndex:r] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4 + 3] = 255;
            }
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256 /*width*/, 1 /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, toneCurveByteArray);
        }
    });
}

#pragma mark -
#pragma mark Accessors

- (GLuint)textureId
{
    NSAssert(textureId, @"Try to use an uninitialized texture! Need call -updateToneCurveTexture");
    return textureId;
}

- (NSArray*)fixedPoints:(NSArray*)points
{
    CGPoint first = [[points objectAtIndex:0] CGPointValue];
    CGPoint last = [[points lastObject] CGPointValue];
    
    if (first.x != 0.0f && first.y != 0.0f && first.x < 0.002f && first.y < 0.02f)
    {
        points = [@[CPoint(0.0f, 0.0f)] arrayByAddingObjectsFromArray:points];
    }
    
    if (last.x != 1.0f && last.y != 1.0f)
    {
        points = [points arrayByAddingObjectsFromArray:@[CPoint(255.0f, 255.0f)]];
    }
    
    return points;
}

- (void)setRGBControlPoints:(NSArray *)points
{
    points = [self fixedPoints:points];
    
    _redCurve = [self getPreparedSplineCurve:points];
    _greenCurve = [self getPreparedSplineCurve:points];
    _blueCurve = [self getPreparedSplineCurve:points];
}

- (void)setRgbCompositeControlPoints:(NSArray *)newValue
{
    _rgbCompositeCurve = [self getPreparedSplineCurve:[self fixedPoints:newValue]];
}


- (void)setRedControlPoints:(NSArray *)newValue
{
    _redCurve = [self getPreparedSplineCurve:[self fixedPoints:newValue]];
}


- (void)setGreenControlPoints:(NSArray *)newValue
{
    _greenCurve = [self getPreparedSplineCurve:[self fixedPoints:newValue]];
}


- (void)setBlueControlPoints:(NSArray *)newValue
{
    _blueCurve = [self getPreparedSplineCurve:[self fixedPoints:newValue]];
}

@end
