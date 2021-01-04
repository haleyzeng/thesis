//
//  CameraOverlayViewController.h
//  Classroom Visual Assistant
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CameraOverlayViewController;

@protocol CameraOverlayViewControllerDelegate <NSObject>

- (void)cameraOverlayViewControllerDidTapStop:(CameraOverlayViewController *)viewController;

- (void)cameraOverlayViewController:(CameraOverlayViewController *)viewController setPause:(BOOL)shouldPause;

@end

@interface CameraOverlayViewController : UIViewController

@property (weak, nonatomic) id<CameraOverlayViewControllerDelegate> delegate;

- (void)setImage:(UIImage *)image;
- (void)setPause:(BOOL)pause;

@end

NS_ASSUME_NONNULL_END
