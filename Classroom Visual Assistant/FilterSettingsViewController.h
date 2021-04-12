//
//  FilterSettingsViewController.h
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 2/16/21.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FilterSettingsViewController;

@protocol FilterSettingsViewControllerDelegate <NSObject>

- (void) filterSettingsViewController:(FilterSettingsViewController *)filterSettingsViewController didChangeFilterSelectionsTo:(NSArray *)filterSelections;

@end

@interface FilterSettingsViewController : ViewController

@property (weak, nonatomic) id<FilterSettingsViewControllerDelegate> delegate;
- (instancetype)initWithAppliedFilters:(NSArray *)applied;

@end

NS_ASSUME_NONNULL_END
