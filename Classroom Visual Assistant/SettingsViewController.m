//
//  SettingsViewController.m
//  Classroom Visual Assistant
//

#import "SettingsViewController.h"
#import "FilterTableViewCell.h"
#import "FilterSettingsViewController.h"
#import "UserDefaultConstants.h"

@interface SettingsViewController () <
FilterTableViewCellDelegate,
FilterSettingsViewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UIButton *timerLengthButton;
@property (weak, nonatomic) IBOutlet UIButton *filterSelectionButton;
@property (strong, nonatomic) NSArray *appliedFilters;
@property (strong, nonatomic) FilterSettingsViewController *filterSettingsVC;
@property (strong, nonatomic) UITableViewController *timerTableVC;
@property (nonatomic) NSInteger timerLengthIndex;
@property (strong, nonatomic) NSArray<NSNumber *> *timerLengths;

@end

const int kSEC_TO_MIN = 60;

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appliedFilters = [[NSUserDefaults standardUserDefaults] objectForKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    self.filterSettingsVC = [[FilterSettingsViewController alloc] initWithAppliedFilters:self.appliedFilters];
    self.filterSettingsVC.delegate = self;
    
    NSNumber *savedTimerLength = [[NSUserDefaults standardUserDefaults] objectForKey:TIMER_LENGTH_USER_DEFAULTS_KEY];
    CGFloat timerLength = savedTimerLength ? [savedTimerLength floatValue] : DEFAULT_TIMER_LENGTH;
    
    self.timerLengthIndex = -1;
    NSMutableArray *timerLengths = [NSMutableArray new];
    for (int i = 0; i < SIZE_OF_TIMER_LENGTHS_ARRAY; i++) {
        [timerLengths addObject:[NSNumber numberWithFloat:TIMER_LENGTHS_ARRAY[i]]];
        if (TIMER_LENGTHS_ARRAY[i] == timerLength) {
            self.timerLengthIndex = i;
        }
    }
    self.timerLengths = [timerLengths copy];
    
    if (self.timerLengthIndex == -1) {
        self.timerLengthIndex = 0;
        [self.delegate settingsViewController:self didChangeTimerLengthTo:[self.timerLengths[0] floatValue]];
    }
    [self updateButtonLabels];
}

- (void)updateButtonLabels {
    [self.filterSelectionButton setTitle:[NSString stringWithFormat:@"%ld applied", [self.appliedFilters count]] forState:UIControlStateNormal];
    NSString *timerLengthButtonText = [self stringForTimerLengthInSeconds:(NSInteger)[self.timerLengths[self.timerLengthIndex] floatValue]];
    [self.timerLengthButton setTitle:timerLengthButtonText forState:UIControlStateNormal];
}

- (IBAction)didTapFilterSelectionButton:(id)sender {
    [self.navigationController pushViewController:self.filterSettingsVC animated:YES];
}

- (void)filterSettingsViewController:(FilterSettingsViewController *)filterSettingsVC didChangeFilterSelectionsTo:(NSArray *)appliedFilters {
    self.appliedFilters = appliedFilters;
    [self updateButtonLabels];
    [self.delegate settingsViewController:self didChangeFilterSelectionsTo:appliedFilters];
}

- (IBAction)didTapTimerLengthButton:(id)sender {
    self.timerTableVC = [UITableViewController new];
    self.timerTableVC.tableView.delegate = self;
    self.timerTableVC.tableView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"FilterTableViewCell" bundle:nil];
        [self.timerTableVC.tableView registerNib:nib forCellReuseIdentifier:@"filterCell"];
    [self.navigationController pushViewController:self.timerTableVC animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilterTableViewCell *cell = [self.timerTableVC.tableView dequeueReusableCellWithIdentifier:@"filterCell"];
    cell.delegate = self;

    CGFloat totSecs = [self.timerLengths[indexPath.row] floatValue];
    
    cell.label.text = [self stringForTimerLengthInSeconds:(NSInteger)totSecs];
    
    if (indexPath.row == self.timerLengthIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)stringForTimerLengthInSeconds:(NSInteger)seconds {
    NSInteger mins = seconds / kSEC_TO_MIN;
    NSInteger secs = seconds % kSEC_TO_MIN;
    if (mins == 0) {
        return [NSString stringWithFormat:@"%ld sec", secs];
    } else if (secs == 0) {
        return [NSString stringWithFormat:@"%ld min", mins];
    } else {
        return [NSString stringWithFormat:@"%ld min %ld sec", mins, secs];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.timerTableVC.tableView) {
        return [self.timerLengths count];
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.timerLengthIndex = indexPath.row;
    CGFloat timerLength = [self.timerLengths[self.timerLengthIndex] floatValue];
    [self.delegate settingsViewController:self didChangeTimerLengthTo:timerLength];
    [self.timerTableVC.tableView reloadData];
    [self updateButtonLabels];
}

- (void)filterTableViewCellDidTapButton:(FilterTableViewCell *)cell {
}

@end
