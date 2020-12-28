//
//  ImageProcessor.h
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 12/15/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageProcessor : NSObject

- (UIImage *) processImage:(UIImage *)image;
- (void)setFiltersList:(NSArray *)filters;

@end

NS_ASSUME_NONNULL_END
