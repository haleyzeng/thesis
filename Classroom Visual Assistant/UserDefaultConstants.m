//
//  UserDefaultConstants.m
//  Classroom Visual Assistant
//
//  Created by Haley Zeng on 11/17/20.
//

#import "UserDefaultConstants.h"

@implementation UserDefaultConstants
NSString *const APPLIED_FILTERS_USER_DEFAULTS_KEY = @"APPLIED_FILTERS";

const int SIZE_OF_FILTER_NAMES_ARRAY = 7;
NSString *const FILTER_NAMES_ARRAY[] = {
    @"BINARIZE",
    @"CANNY_EDGE_DETECT",
    @"COLOR_INVERT",
    @"GAUSSIAN_BLUR",
    @"HISTOGRAM_EQUALIZE",
    @"ISOLATE_BOARD",
    @"SIMPLE_THRESHOLD"
};
@end
