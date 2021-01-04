//
//  DualSessionCameraOverlayViewController.m
//  Classroom Visual Assistant
//

#import "DualSessionCameraOverlayViewController.h"

@interface DualSessionCameraOverlayViewController ()

@property (weak, nonatomic) IBOutlet UIButton *endSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (nonatomic) BOOL isPaused;

@end

@implementation DualSessionCameraOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setPause:(BOOL)pause {
    if (pause == self.pauseButton.selected) {
        return;
    }
    [self.pauseButton setSelected:pause];
    self.isPaused = pause;
    [self.delegate dualSessionCameraOverlayViewController:self setPause:pause];
}

- (IBAction)didTapEndSession:(id)sender {
    [self.delegate dualSessionCameraOverlayViewControllerDidTapStop:self];
}

- (IBAction)didTapPause:(id)sender {
    [self setPause:!self.isPaused];
}

@end
