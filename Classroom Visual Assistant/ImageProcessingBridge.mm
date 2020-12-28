//
//  ImageProcessingBridge.mm
//  Classroom Visual Assistant
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <Foundation/Foundation.h>

#import "ImageProcessingBridge.h"
#import "ImageProcessor.hpp"

@implementation ImageProcessingBridge

- (UIImage *)processImage:(UIImage *)image withFilters:(NSArray *)filters{
    cv::Mat mat;
    UIImageToMat(image, mat, true);
   
    std::vector<std::string> filtersVector(0);
    for (NSString *filterName in filters) {
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
