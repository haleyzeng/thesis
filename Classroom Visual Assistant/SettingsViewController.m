//
//  SettingsViewController.m
//  Classroom Visual Assistant
//

#import "SettingsViewController.h"
#import "FilterTableViewCell.h"
#import "UserDefaultConstants.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, FilterTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *appliedFilters;
@property (strong, nonatomic) NSMutableArray *notAppliedFilters;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSArray *applied = [[NSUserDefaults standardUserDefaults] objectForKey:APPLIED_FILTERS_USER_DEFAULTS_KEY];
    
    self.appliedFilters = [[NSMutableArray alloc] initWithArray:applied];
    
    self.notAppliedFilters = [NSMutableArray new];
    for (int i = 0; i < SIZE_OF_FILTER_NAMES_ARRAY; i++) {
        if (![self.appliedFilters containsObject:FILTER_NAMES_ARRAY[i]]) {
            [self.notAppliedFilters addObject:FILTER_NAMES_ARRAY[i]];
        }
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setEditing:YES];
    UINib *nib = [UINib nibWithNibName:@"FilterTableViewCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"filterCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.appliedFilters.count;
    } else {
        return self.notAppliedFilters.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Applied";
    } else {
        return @"Not Applied";
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilterTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"filterCell"];
    cell.delegate = self;
    if (indexPath.section == 0) {
        cell.label.text = self.appliedFilters[indexPath.row];
        [cell.button setTitle:@"-" forState:UIControlStateNormal];
    } else {
        cell.label.text = self.notAppliedFilters[indexPath.row];
        [cell.button setTitle:@"+" forState:UIControlStateNormal];
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
  if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
    NSInteger row = 0;
    if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
      row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
    }
    return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
  }

  return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.appliedFilters exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

- (void)filterTableViewCellDidTapButton:(FilterTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0) {
        NSString *o = self.appliedFilters[indexPath.row];
        [self.appliedFilters removeObjectAtIndex:indexPath.row];
        [self.notAppliedFilters addObject:o];
    } else {
        NSString *o = self.notAppliedFilters[indexPath.row];
        [self.notAppliedFilters removeObjectAtIndex:indexPath.row];
        [self.appliedFilters addObject:o];
    }
    [self.tableView reloadData];
}


- (IBAction)didTapSaveButton:(id)sender {
    [self.delegate settingsViewController:self didChangeFilterSelectionsTo:[self.appliedFilters copy]];
    [self.delegate settingsViewControllerWillDismiss:self];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
