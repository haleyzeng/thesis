//
//  ImageProcessingBridge.mm
//  Classroom Visual Assistant
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <Foundation/Foundation.h>

#import "ImageProcessingBridge.h"
#import "ImageProcessor.hpp"

@interface ImageProcessingBridge ()
@property (strong, nonatomic) NSArray *filters;
@end

@implementation ImageProcessingBridge

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.filters = [NSArray new];
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
    
    cv::Mat mat;
    UIImageToMat(normalizedImage, mat, true);
   
    std::vector<std::string> filtersVector(0);
    for (NSString *filterName in self.filters) {
        filtersVector.push_back([self convertNSStringToCppString:filterName]);
    }
    
   Mat processedImage = ImageProcessor::applyFilters(mat, filtersVector);
    return MatToUIImage(processedImage);
}

- (std::string)convertNSStringToCppString:(NSString *)s {
    return std::string([s UTF8String]);
}

- (NSString *)converCppStringToNSString:(std::string)s {
    return [NSString stringWithCString:s.c_str() encoding:[NSString defaultCStringEncoding]];
}

@end
