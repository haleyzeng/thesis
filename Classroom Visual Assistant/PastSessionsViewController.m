//
//  PastSessionsViewController.m
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 1/5/21.
//

#import "PastSessionsViewController.h"
#import "SettingsViewController.h"
#import "ImageProcessor.h"
#import "MWPhotoBrowser.h"

@interface PastSessionsViewController () <UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSArray<NSString *> *sessionDirNames;
@property (strong, nonatomic) NSMutableArray<MWPhoto *> *photos;

@end

@implementation PastSessionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.documentsDirectory = documentsDirectory;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray <NSString *> *sessionDirNames = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 intValue] == [obj2 intValue])
            return NSOrderedSame;
        else if ([obj1 intValue] < [obj2 intValue])
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    self.sessionDirNames = [sessionDirNames sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.photos = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sessionDirNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"pastSessionCell"];
    NSTimeInterval time = [self.sessionDirNames[indexPath.row] intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"EEE MMM dd yyy hh:mm aa"];
    
    [cell.textLabel setText:[dateFormatter stringFromDate:date]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sessionDirName = self.sessionDirNames[indexPath.row];
    NSString *dirpath = [self.documentsDirectory stringByAppendingPathComponent:sessionDirName];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray <NSString *> *photoFilenames = [filemgr contentsOfDirectoryAtPath:dirpath error:nil];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 intValue] == [obj2 intValue])
            return NSOrderedSame;
        else if ([obj1 intValue] < [obj2 intValue])
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    photoFilenames = [photoFilenames sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.photos = [NSMutableArray new];
    for (int i = 0; i < [photoFilenames count]; i++) {
        NSString *filepath = [dirpath stringByAppendingPathComponent:photoFilenames[i]];
        NSURL *url = [NSURL fileURLWithPath:filepath];
        [self.photos addObject:[MWPhoto photoWithURL:url]];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.displayActionButton = YES;
    browser.alwaysShowControls = YES;
    
    [self.navigationController pushViewController:browser animated:YES];
}


- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.photos count];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return self.photos[index];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return self.photos[index];
}

@end
