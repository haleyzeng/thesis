//
//  CameraOverlayViewController.mm
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 10/4/20.
//

#import <opencv2/opencv.hpp>

#import "CameraOverlayViewController.h"
#import "ImageProcessingBridge.h"
#import "SettingsViewController.h"
#import "UserDefaultConstants.h"

@interface CameraOverlayViewController () <UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, SettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) ImageProcessingBridge *imageProcessingBridge;
@property (nonatomic) BOOL pauseByUser;
@end

@implementation CameraOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.delegate = self;
    self.imageProcessingBridge = [ImageProcessingBridge new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *filters = [userDefaults arrayForKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    if (filters == nil) {
        filters = @[];
        [userDefaults setObject:@[] forKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    }
    [self.imageProcessingBridge setFiltersList:filters];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = [self.imageProcessingBridge processImage:image];
}

- (IBAction)didTapStop:(id)sender {
    [self.delegate didTapStop];
}

- (IBAction)didTapPause:(id)sender {
    [self setPause:!self.pauseButton.isSelected fromSender:sender];
}

- (void)setPause:(BOOL)pause fromSender:(id)sender {
    /* If user manually paused, that action overrides any programmatic pause/unpause. */
    if (self.pauseByUser && sender != self.pauseButton) {
        return;
    }
    self.pauseByUser = pause && sender == self.pauseButton;
    [self.pauseButton setSelected:pause];
    [self.delegate setPause:pause];
}

- (IBAction)didTapSettings:(id)sender {
    [self setPause:YES fromSender:sender];
    SettingsViewController *settingsVC = [SettingsViewController new];
    settingsVC.modalPresentationStyle = UIModalPresentationPopover;
    settingsVC.delegate = self;
    [self presentViewController:settingsVC animated:YES completion:nil];
    UIPopoverPresentationController *popController = [settingsVC popoverPresentationController];
       popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
       popController.sourceView = self.settingsButton;
       popController.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    [self setPause:NO fromSender:presentationController];
}

- (void)settingsViewControllerWillDismiss:(SettingsViewController *)settingsViewController {
    [self setPause:NO fromSender:settingsViewController];
}

- (void)settingsViewController:(SettingsViewController *)settingsViewController didChangeFilterSelectionsTo:(NSArray *)filterSelections {
    [[NSUserDefaults standardUserDefaults] setObject:filterSelections forKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    [self.imageProcessingBridge setFiltersList:filterSelections];
}

@end
