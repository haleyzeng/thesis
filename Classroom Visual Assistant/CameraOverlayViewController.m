//
//  CameraOverlayViewController.m
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 10/4/20.
//

#import "CameraOverlayViewController.h"

@interface CameraOverlayViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@end

@implementation CameraOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.delegate = self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (IBAction)didTapStop:(id)sender {
    [self.delegate didTapStop];
}

- (IBAction)didTapPause:(id)sender {
    [self.pauseButton setSelected:!self.pauseButton.isSelected];
    [self.delegate didTapPause:self.pauseButton.isSelected];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
