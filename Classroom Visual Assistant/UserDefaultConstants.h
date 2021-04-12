//
//  UserDefaultConstants.h
//  Classroom Visual Assistant
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaultConstants : NSObject

extern NSString *const APPLIED_FILTERS_USER_DEFAULTS_KEY;
extern NSString *const TIMER_LENGTH_USER_DEFAULTS_KEY;

extern const float DEFAULT_TIMER_LENGTH;

extern const int SIZE_OF_FILTER_NAMES_ARRAY;
extern NSString * _Nonnull const FILTER_NAMES_ARRAY[];
extern const int SIZE_OF_TIMER_LENGTHS_ARRAY;
extern const int TIMER_LENGTHS_ARRAY[];
@end

NS_ASSUME_NONNULL_END
