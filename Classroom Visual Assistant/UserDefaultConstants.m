//
//  UserDefaultConstants.m
//  Classroom Visual Assistant
//

#import "UserDefaultConstants.h"

@implementation UserDefaultConstants
NSString *const APPLIED_FILTERS_USER_DEFAULTS_KEY = @"APPLIED_FILTERS";
NSString *const TIMER_LENGTH_USER_DEFAULTS_KEY = @"TIMER_LENGTH";

const float DEFAULT_TIMER_LENGTH = 30.0;

const int SIZE_OF_FILTER_NAMES_ARRAY = 8;
NSString *const FILTER_NAMES_ARRAY[] = {
    @"BINARIZE",
    @"CANNY_EDGE_DETECT",
    @"COLOR_INVERT",
    @"GAUSSIAN_BLUR",
    @"HISTOGRAM_EQUALIZE",
    @"ISOLATE_BOARD",
    @"SIMPLE_THRESHOLD",
    @"GREYSCALE"
};

const int SIZE_OF_TIMER_LENGTHS_ARRAY = 8;
const int TIMER_LENGTHS_ARRAY[] = {
    5,
    10,
    20,
    30,
    60,
    120,
    180,
    300
};
@end
