//
//  CameraOverlayViewController.mm
//  Classroom Visual Assistant
//

#import <opencv2/opencv.hpp>

#import "CameraOverlayViewController.h"
#import "ImageProcessor.h"
#import "SettingsViewController.h"
#import "UserDefaultConstants.h"

@interface CameraOverlayViewController () <UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, SettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *prevImageButton;
@property (weak, nonatomic) IBOutlet UIButton *nextImageButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;

@property (strong, nonatomic) ImageProcessor *imageProcessor;

@property (strong, nonatomic) NSMutableArray<UIImage *> *previousImagesStack;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *isPreviousImageStarred;
@property (nonatomic) int previousImageIndex;

@property (nonatomic) BOOL pauseByUser;

@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *directoryPath;
@property (nonatomic) int savedPhotoIndex;
@end

@implementation CameraOverlayViewController

const int kPREVIOUS_IMAGES_STACK_MAX_SIZE = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.delegate = self;
    
    self.previousImagesStack = [NSMutableArray new];
    self.isPreviousImageStarred = [NSMutableArray new];
    self.previousImageIndex = -1;
    [self setPrevImageButtonEnabled];
    [self setNextImageButtonEnabled];
    
    self.imageProcessor = [ImageProcessor new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *filters = [userDefaults arrayForKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    if (filters == nil) {
        filters = @[];
        [userDefaults setObject:@[] forKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    }
    [self.imageProcessor setFiltersList:filters];
    
    self.timestamp = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
    self.savedPhotoIndex = 0;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setImage:(UIImage *)image {
    UIImage *processedImage = [self.imageProcessor processImage:image];
    [self pushToPreviousImagesStack:processedImage];
    [self setPrevImageButtonEnabled];
    [self setStarButtonSelected];
    [self displayImage:processedImage];
}

- (void)displayImage:(UIImage *)image {
    self.imageView.image = image;
}

- (IBAction)didTapStop:(id)sender {
    [self savePreviousImagesToStorage];
    [self.delegate cameraOverlayViewControllerDidTapStop:self];
}

- (IBAction)didTapPause:(id)sender {
    [self setPause:!self.pauseButton.isSelected fromSender:sender];
}

- (void)setPause:(BOOL)pause {
    [self setPause:pause fromSender:self.pauseButton];
}

- (void)setPause:(BOOL)pause fromSender:(id)sender {
    if (pause == self.pauseButton.isSelected) {
        return;
    }
    /* If user manually paused, that action overrides any programmatic pause/unpause. */
    if (self.pauseByUser && sender != self.pauseButton) {
        return;
    }
    self.pauseByUser = pause && sender == self.pauseButton;
    [self.pauseButton setSelected:pause];
    
    if (!pause) {
        self.previousImageIndex = -1;
        if ([self.previousImagesStack count] == 0) {
            [self displayImage:nil];
        } else {
            [self displayImage:self.previousImagesStack[[self.previousImagesStack count] - 1]];
        }
    }
    
    [self.delegate cameraOverlayViewController:self setPause:pause];
}

- (void)pushToPreviousImagesStack:(UIImage *)image {
    if (self.previousImageIndex != -1) {
        NSLog(@"Error: pushToPreviousImagesStack called when user is viewing a previous image.");
    } else {
        [self.previousImagesStack addObject:image];
        [self.isPreviousImageStarred addObject:@NO];
        if ([self.previousImagesStack count] > kPREVIOUS_IMAGES_STACK_MAX_SIZE) {
            if ([self.isPreviousImageStarred[0] boolValue]) {
                [self saveImageToStorage:self.previousImagesStack[0]];
            }
            [self.previousImagesStack removeObjectAtIndex:0];
            [self.isPreviousImageStarred removeObjectAtIndex:0];
        }
    }
}

- (IBAction)didTapPrev:(id)sender {
    if (self.previousImageIndex == -1) {
        [self setPause:YES fromSender:sender];
        self.previousImageIndex = (int) [self.previousImagesStack count] - 2;
    } else if (self.previousImageIndex == 0) {
        NSLog(@"Error: didTapPrev triggered when prev button should be disabled.");
    } else {
        self.previousImageIndex -= 1;
    }
    [self setPrevImageButtonEnabled];
    [self setNextImageButtonEnabled];
    [self setImageBasedOnPreviousImageIndex];
    [self setStarButtonSelected];
}

- (IBAction)didTapNext:(id)sender {
    if (self.previousImageIndex == -1) {
        NSLog(@"Error: didTapNext triggered when next button should be disabled.");
    } else {
        self.previousImageIndex += 1;
    }
    [self setPrevImageButtonEnabled];
    [self setNextImageButtonEnabled];
    [self setImageBasedOnPreviousImageIndex];
    [self setStarButtonSelected];
}

- (void)setImageBasedOnPreviousImageIndex {
    [self displayImage:self.previousImagesStack[self.previousImageIndex]];
}

- (void)setPrevImageButtonEnabled {
    BOOL enabled = [self.previousImagesStack count] > 1 &&
    (self.previousImageIndex > 0 || self.previousImageIndex == -1);
    
    [self.prevImageButton setEnabled:enabled];
    [self.prevImageButton setAlpha:enabled ? 1.0 : 0.5];
}

- (void)setNextImageButtonEnabled {
    BOOL enabled = self.previousImageIndex != -1 &&
    self.previousImageIndex < [self.previousImagesStack count] - 1;
    
    [self.nextImageButton setEnabled:enabled];
    [self.nextImageButton setAlpha:enabled ? 1.0 : 0.5];
}

-(void)setStarButtonSelected {
    NSInteger i = self.previousImageIndex;
    if (self.previousImageIndex == -1) {
        i = [self.previousImagesStack count] - 1;
    }
    [self.starButton setSelected:[self.isPreviousImageStarred[i] boolValue]];
}

- (IBAction)didTapStar:(id)sender {
    BOOL selectedValue = !self.starButton.selected;
    [self.starButton setSelected:selectedValue];
    NSInteger i = self.previousImageIndex;
    if (self.previousImageIndex == -1) {
        i = [self.previousImagesStack count] - 1;
    }
    self.isPreviousImageStarred[i] = [NSNumber numberWithBool:selectedValue];
}

- (void)savePreviousImagesToStorage {
    for (int i = 0; i < [self.isPreviousImageStarred count]; i++) {
        if ([self.isPreviousImageStarred[i] boolValue]) {
            [self saveImageToStorage:self.previousImagesStack[i]];
        }
    }
}

- (void)saveImageToStorage:(UIImage *)image {
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if (self.directoryPath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.directoryPath = [documentsDirectory stringByAppendingPathComponent:self.timestamp];
        NSURL *url = [NSURL fileURLWithPath:self.directoryPath];
        NSError *error = nil;
        BOOL succ = [filemgr createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:&error];
        if (!succ) {
            NSLog(@"Failed to create directory for session photo storage.");
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
    }
    
    NSString *filename = [NSString stringWithFormat:@"%d.jpg", self.savedPhotoIndex];
    NSURL *url = [NSURL fileURLWithPath:[self.directoryPath stringByAppendingPathComponent:filename]];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSError *error = nil;
    BOOL succ = [data writeToURL:url options:NSDataWritingAtomic error:&error];
    if (!succ) {
        NSLog(@"Failed to save photo to storage.");
        NSLog(@"Error: %@", error.localizedDescription);
    }
    self.savedPhotoIndex += 1;
}

- (IBAction)didTapSettings:(id)sender {
    [self setPause:YES fromSender:sender];
    
    SettingsViewController *settingsVC = [SettingsViewController new];
    settingsVC.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    navController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popController = [navController popoverPresentationController];
       popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
       popController.sourceView = self.settingsButton;
       popController.delegate = self;
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    [self setPause:NO fromSender:presentationController];
}

- (void)settingsViewControllerWillDismiss:(SettingsViewController *)settingsViewController {
    [self setPause:NO fromSender:settingsViewController];
}

- (void)settingsViewController:(SettingsViewController *)settingsViewController didChangeFilterSelectionsTo:(NSArray *)filterSelections {
    [[NSUserDefaults standardUserDefaults] setObject:filterSelections forKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    [self.imageProcessor setFiltersList:filterSelections];
}

- (void)settingsViewController:(SettingsViewController *)settingsViewController didChangeTimerLengthTo:(CGFloat)timerLength {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:timerLength] forKey:TIMER_LENGTH_USER_DEFAULTS_KEY];
    [self.delegate cameraOverlayViewController:self setTimerLength:timerLength];
}

@end
