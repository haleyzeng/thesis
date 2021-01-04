//
//  SettingsViewController.h
//  Classroom Visual Assistant
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>

- (void) settingsViewControllerWillDismiss:(SettingsViewController *)settingsViewController;
- (void) settingsViewController:(SettingsViewController *)settingsViewController didChangeFilterSelectionsTo:(NSArray *)filterSelections;

@end

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) id<SettingsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
