//
//  FilterTableViewCell.h
//  Classroom Visual Assistant
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FilterTableViewCell;

@protocol FilterTableViewCellDelegate <NSObject>

- (void) filterTableViewCellDidTapButton:(FilterTableViewCell *)cell;

@end

@interface FilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) id<FilterTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
