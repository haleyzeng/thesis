//
//  ViewController.m
//  Classroom Visual Assistant
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CameraOverlayViewController.h"
#import "DualSessionCameraOverlayViewController.h"
#import "ViewController.h"

typedef NS_ENUM(NSInteger, DualSessionDeviceType) {
    DualSessionDeviceTypeDisplay,
    DualSessionDeviceTypeCamera
};

typedef NS_ENUM(NSInteger, CVASessionType) {
    CVASessionTypeSingleDevice,
    CVASessionTypeDualDevice
};

typedef NS_ENUM(NSInteger, MCSessionDataType) {
    MCSessionDataTypeImage,
    MCSessionDataTypePauseCommand
};


@interface ViewController () <
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CameraOverlayViewControllerDelegate,
DualSessionCameraOverlayViewControllerDelegate,
MCBrowserViewControllerDelegate,
MCNearbyServiceAdvertiserDelegate,
MCSessionDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *startSingleDeviceSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *startDualDeviceSessionButton;

@property (nonatomic) CVASessionType cvaSessionType;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) CameraOverlayViewController *cameraOverlayVC;
@property (strong, nonatomic) DualSessionCameraOverlayViewController *dualSessionCameraOverlayVC;
@property (strong, nonatomic) NSTimer *timer;


@property (nonatomic) DualSessionDeviceType deviceType;
@property (strong, nonatomic) MCPeerID *thisPeerID;
@property (strong, nonatomic) MCPeerID *secondDevicePeerID;
@property (strong, nonatomic) MCSession *mcSession;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *mcAdvertiser;
@property (strong, nonatomic) MCBrowserViewController *mcBrowserVC;

@end

@implementation ViewController

const float kTIMER_LENGTH = 5.0;
NSString *const DUAL_SESSION_CONNECTION_SERVICE_NAME = @"cva-session";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startSingleDeviceSession:(id)sender {
    self.cvaSessionType = CVASessionTypeSingleDevice;
    [self startCameraSessionForCVASessionType:CVASessionTypeSingleDevice];
}

- (IBAction)startDualDeviceSession:(id)sender {
    self.cvaSessionType = CVASessionTypeDualDevice;
    UIAlertController *dualSessionActionSheet = [UIAlertController alertControllerWithTitle:@"Dual Session" message:@"Start dual session with this device as" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *optionDisplay = [UIAlertAction actionWithTitle:@"Display" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createDualSessionConnectionAsDeviceType:DualSessionDeviceTypeDisplay];
    }];
    UIAlertAction *optionCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createDualSessionConnectionAsDeviceType:DualSessionDeviceTypeCamera];
    }];
    
    [dualSessionActionSheet addAction:optionDisplay];
    [dualSessionActionSheet addAction:optionCamera];
    
    if ([dualSessionActionSheet popoverPresentationController] != nil) {
        [dualSessionActionSheet popoverPresentationController].sourceView = self.startDualDeviceSessionButton;
    }
    
    [self presentViewController:dualSessionActionSheet animated:YES completion:nil];
}

- (void)createDualSessionConnectionAsDeviceType:(DualSessionDeviceType)deviceType {
    self.deviceType = deviceType;
    self.thisPeerID = [[MCPeerID alloc] initWithDisplayName:UIDevice.currentDevice.name];
    self.mcSession = [[MCSession alloc] initWithPeer:self.thisPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.mcSession.delegate = self;
    
    switch (self.deviceType) {
        case DualSessionDeviceTypeDisplay: {
            self.mcBrowserVC = [[MCBrowserViewController alloc] initWithServiceType:DUAL_SESSION_CONNECTION_SERVICE_NAME session:self.mcSession];
            self.mcBrowserVC.minimumNumberOfPeers = 2;
            self.mcBrowserVC.maximumNumberOfPeers = 2;
            self.mcBrowserVC.delegate = self;
            
            [self presentViewController:self.mcBrowserVC animated:YES completion:nil];
            break;
        }
        case DualSessionDeviceTypeCamera: {
            self.mcAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.thisPeerID discoveryInfo:nil serviceType:DUAL_SESSION_CONNECTION_SERVICE_NAME];
            self.mcAdvertiser.delegate = self;
            [self.mcAdvertiser startAdvertisingPeer];
            
            UIAlertController *waitingToConnectAlert = [UIAlertController alertControllerWithTitle:@"Waiting to connect with display device..." message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [waitingToConnectAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.mcAdvertiser stopAdvertisingPeer];
            }]];
            
            [self presentViewController:waitingToConnectAlert animated:YES completion:nil];
            
            break;
        }
    }
}

- (void)startCameraSessionForCVASessionType:(CVASessionType)sessionType {
    self.imagePicker = [UIImagePickerController new];
    
    // if camera is not an option, show error
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
                         completion:nil];
    }
    else {
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.showsCameraControls = NO;
        
        switch (sessionType) {
            case CVASessionTypeSingleDevice: {
                self.cameraOverlayVC = [[CameraOverlayViewController alloc] initWithNibName:@"CameraOverlayViewController" bundle:nil];
                self.cameraOverlayVC.delegate = self;
                self.imagePicker.cameraOverlayView = self.cameraOverlayVC.view;
                self.imagePicker.cameraViewTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(.15, .15), 2200, 3000);
                break;
            }
            case CVASessionTypeDualDevice: {
                self.dualSessionCameraOverlayVC = [[DualSessionCameraOverlayViewController alloc] initWithNibName:@"DualSessionCameraOverlayViewController" bundle:nil];
                self.dualSessionCameraOverlayVC.delegate = self;
                self.imagePicker.cameraOverlayView = self.dualSessionCameraOverlayVC.view;
                break;
            }
        }
        
        [self presentViewController:self.imagePicker
                           animated:YES
                         completion:nil];
        [self startTimer];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    switch (self.cvaSessionType) {
        case CVASessionTypeSingleDevice: {
            [self.cameraOverlayVC setImage:image];
            break;
        }
        case CVASessionTypeDualDevice: {
            [self sendImageToPeer:info[UIImagePickerControllerOriginalImage]];
        }
    }
}

- (void)startTimer {
    [self endTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTIMER_LENGTH target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
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

- (void)sendPauseCommandToPeer:(BOOL)pause {
    if (self.mcSession && self.secondDevicePeerID) {
        NSInteger dataType = MCSessionDataTypePauseCommand;
        NSMutableData *allData = [NSMutableData dataWithBytes:&dataType length:sizeof(dataType)];
        NSData *booleanData = [NSData dataWithBytes:&pause length:sizeof(pause)];
        [allData appendData:booleanData];
        [self.mcSession sendData:allData toPeers:@[self.secondDevicePeerID] withMode:MCSessionSendDataReliable error:nil];
    }
}

- (void)sendImageToPeer:(UIImage *)image {
    if (self.mcSession && self.secondDevicePeerID) {
        NSInteger dataType = MCSessionDataTypeImage;
        NSMutableData *allData = [NSMutableData dataWithBytes:&dataType length:sizeof(dataType)];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        [allData appendData:imageData];
        [self.mcSession sendData:allData toPeers:@[self.secondDevicePeerID] withMode:MCSessionSendDataReliable error:nil];
    }
}

- (void)handlePeerDisconnected {
    NSLog(@"Peer disconnected");
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Disconnected"
                                message:@"The other device disconnected. Ending session."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }];
    
}

#pragma mark - CameraOverlayViewControllerDelegate

- (void)cameraOverlayViewControllerDidTapStop:(CameraOverlayViewController *)viewController {
    [self endTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mcSession disconnect];
    self.mcSession = nil;
}

- (void)cameraOverlayViewController:(CameraOverlayViewController *)viewController setPause:(BOOL)shouldPause {
    [self sendPauseCommandToPeer:shouldPause];
    if (shouldPause) {
        [self endTimer];
    } else {
        [self startTimer];
    }
}

#pragma mark - DualSessionCameraOverlayViewControllerDelegate

- (void)dualSessionCameraOverlayViewControllerDidTapStop:(DualSessionCameraOverlayViewController *)viewController {
    [self endTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mcSession disconnect];
    self.mcSession = nil;
}

- (void)dualSessionCameraOverlayViewController:(DualSessionCameraOverlayViewController *)viewController setPause:(BOOL)shouldPause {
    [self sendPauseCommandToPeer:shouldPause];
    if (shouldPause) {
        [self endTimer];
    } else {
        [self startTimer];
    }
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    self.mcBrowserVC = nil;
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.mcBrowserVC = nil;
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if (self.cvaSessionType == CVASessionTypeDualDevice) {
        NSInteger dataType;
        [data getBytes:&dataType length:sizeof(dataType)];
        NSUInteger loc = sizeof(dataType);
        NSUInteger len = [data length] - loc;
        NSData *contents = [data subdataWithRange:NSMakeRange(loc, len)];
        switch (dataType) {
            case MCSessionDataTypeImage: {
                UIImage *image = [UIImage imageWithData:contents];
                if (image)  {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.cameraOverlayVC setImage:image];
                    });
                }
                break;
            }
            case MCSessionDataTypePauseCommand: {
                BOOL pause;
                [contents getBytes:&pause length:sizeof(pause)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.deviceType == DualSessionDeviceTypeDisplay) {
                        [self.cameraOverlayVC setPause:pause];
                        
                    } else if (self.deviceType == DualSessionDeviceTypeCamera) {
                        [self.dualSessionCameraOverlayVC setPause:pause];
                    }
                });
                break;
            }
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (session == self.mcSession && peerID != self.thisPeerID && state == MCSessionStateConnected) {
        switch (self.deviceType) {
            case DualSessionDeviceTypeDisplay: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.secondDevicePeerID = peerID;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    self.cameraOverlayVC = [[CameraOverlayViewController alloc] initWithNibName:@"CameraOverlayViewController" bundle:nil];
                    self.cameraOverlayVC.delegate = self;
                    self.cameraOverlayVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:self.cameraOverlayVC animated:YES completion:nil];
                });
                break;
            }
            case DualSessionDeviceTypeCamera: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.secondDevicePeerID = peerID;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self startCameraSessionForCVASessionType:CVASessionTypeDualDevice];
                });
                break;
            }
        }
    } else if (session == self.mcSession && peerID == self.secondDevicePeerID && state == MCSessionStateNotConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handlePeerDisconnected];
        });
    }
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    invitationHandler(YES, self.mcSession);
}


@end

