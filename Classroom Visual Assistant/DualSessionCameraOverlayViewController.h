//
//  DualSessionCameraOverlayViewController.h
//  Classroom Visual Assistant
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DualSessionCameraOverlayViewController;

@protocol DualSessionCameraOverlayViewControllerDelegate <NSObject>

- (void)dualSessionCameraOverlayViewControllerDidTapStop:(DualSessionCameraOverlayViewController *)viewController;

- (void)dualSessionCameraOverlayViewController:(DualSessionCameraOverlayViewController *)viewController setPause:(BOOL)shouldPause;

@end

@interface DualSessionCameraOverlayViewController : UIViewController

@property (weak, nonatomic) id<DualSessionCameraOverlayViewControllerDelegate> delegate;

- (void)setPause:(BOOL)pause;

@end

NS_ASSUME_NONNULL_END
