//
//  FilterTableViewCell.m
//  Classroom Visual Assistant
//

#import "FilterTableViewCell.h"

@implementation FilterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapButton:(id)sender {
    [self.delegate filterTableViewCellDidTapButton:self];
}

@end
