//
//  CameraOverlayViewController.h
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 10/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol CameraOverlayViewControllerDelegate <NSObject>

- (void) didTapStop;

- (void) setPause:(BOOL)shouldPause;

@end

@interface CameraOverlayViewController : UIViewController

@property (weak, nonatomic) id<CameraOverlayViewControllerDelegate> delegate;

- (void) setImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
