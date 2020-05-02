//
//  Formats.h
//  S5
//
//  Created by Dan Park on 6/8/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Formats : NSObject

+ (NSString*)noLastCall;
+ (NSString*)makeACall;
+ (NSString*)stringInteger:(NSInteger)number;
+ (NSString*)formatInteger:(NSInteger)number;
+ (NSString*)formatNumber:(NSNumber*)number;
+ (NSString*)formatTimestamp:(NSDate*)date;
+ (NSString*)formatMediumTimestamp:(NSDate*)date;
+ (NSString*)formatShortTimestamp:(NSDate*)date;
+ (NSString*)formatNoDateTimestamp:(NSDate*)date;
+ (NSString*)formatFullDateTimestamp:(NSDate*)date;
+ (NSString*)formatShortTimeOnly:(NSDate*)date;


+ (NSString*)backgroundTimeRemaining;

+ (NSString*)daysUnitString:(NSInteger)days;
+ (NSString*)daysLeftString:(NSInteger)days;
+ (NSString*)relativeDaysLeftString:(NSInteger)days;

+ (NSInteger)minutesUsed:(NSInteger)seconds;

+ (NSString*)hoursUnit:(NSInteger)number;
+ (NSString*)minutesUnit:(NSInteger)number;
+ (NSString*)secondsUnit:(NSInteger)number;
+ (NSString*)secondsInVariantUnit:(NSInteger)seconds;


+ (NSString*)shortHoursUnit:(NSInteger)number;
+ (NSString*)shortMinutesUnit:(NSInteger)number;
+ (NSString*)shortSecondsUnit:(NSInteger)number;

+ (NSString*)hoursMinsSeconds:(NSInteger)seconds;
+ (NSString*)hoursMinsSeconds:(NSInteger)seconds shortForm:(BOOL)shortForm;

+ (NSString*)minsSeconds:(NSInteger)seconds;
+ (NSString*)daysHoursMins:(NSInteger)minutes;

+ (NSString*)trueMinsSeconds:(NSInteger)seconds;
+ (NSString*)trueHoursMinsSeconds:(NSInteger)seconds;

+ (NSString*)formatWeekendMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly isUnlimited:(BOOL)unlimited;
+ (NSString*)formatNightMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly isUnlimited:(BOOL)unlimited;
+ (NSString*)formatMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly isUnlimited:(BOOL)unlimited;


//+ (NSString*)formatMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly;
//+ (NSString*)formatNightMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly;
//+ (NSString*)formatWeekendMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly;
+ (NSString*)shortFormatMinuteUsage:(NSInteger)number;

@end
