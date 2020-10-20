//
//  StartViewController.m
//  ClassroomVisualAssistant
//

#import "ViewController.h"
#import "CameraOverlayViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) CameraOverlayViewController *cameraOverlayVC;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.button addTarget:self
                    action:@selector(startSession:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)startSession:(id)sender {
    self.imagePicker = [UIImagePickerController new];
    
    // if camera is not an option, show photo library
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        UIAlertController *errorAlert = [UIAlertController
                                         alertControllerWithTitle:@"Error"
                                         message:@"Unable to access device's camera."
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        [errorAlert addAction:[UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:errorAlert
                           animated:YES
                         completion:^{}];
    }
    else {
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.showsCameraControls = NO;

        self.cameraOverlayVC = [[CameraOverlayViewController alloc] initWithNibName:@"CameraOverlayViewController" bundle:nil];
        self.cameraOverlayVC.delegate = self;
        self.imagePicker.cameraOverlayView = self.cameraOverlayVC.view;
        self.imagePicker.cameraViewTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(.15, .15), 2200, 3000);
        
        
        [self presentViewController:self.imagePicker
                           animated:YES
                         completion:nil];
        [self startTimer];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.cameraOverlayVC setImage:info[UIImagePickerControllerOriginalImage]];
}

- (void)didTapStop {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self endTimer];
}

- (void)didTapPause:(BOOL)shouldPause {
    if (shouldPause) {
        [self endTimer];
    } else {
        [self startTimer];
    }
}

- (void)startTimer {
    [self endTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)endTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerFired:(NSTimer *)timer {
    if (timer == self.timer) {
        [self.imagePicker takePicture];
    } else {
        [self endTimer];
    }
}

@end
