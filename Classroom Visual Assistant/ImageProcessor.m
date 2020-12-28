//
//  ImageProcessor.m
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 12/15/20.
//

#import "ImageProcessor.h"
#import "ImageProcessingBridge.h"

@interface ImageProcessor ()

@property (strong, nonatomic) NSArray *filters;
@property (strong, nonatomic) ImageProcessingBridge *imageProcessingBridge;
@end

@implementation ImageProcessor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.filters = [NSArray new];
        self.imageProcessingBridge = [ImageProcessingBridge new];
    }
    return self;
}

- (void)setFiltersList:(NSArray *)filters {
    self.filters = filters;
}

- (UIImage *)normalizeImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage *)processImage:(UIImage *)image {
    // normalize image to account for portrait/landscape
    UIImage *normalizedImage = [self normalizeImage:image];
    return [self.imageProcessingBridge processImage:normalizedImage withFilters:self.filters];
}

@end
