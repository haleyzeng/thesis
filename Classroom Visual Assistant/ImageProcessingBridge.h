//
//  ImageProcessingBridge.h
//  Classroom Visual Assistant
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageProcessingBridge : NSObject

- (UIImage *)processImage:(UIImage *)image withFilters:(NSArray *)filters;

@end
