//
//  ImageProcessor.h
//  Classroom Visual Assistant
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageProcessor : NSObject

- (UIImage *)processImage:(UIImage *)image;
- (void)setFiltersList:(NSArray *)filters;

@end

NS_ASSUME_NONNULL_END
