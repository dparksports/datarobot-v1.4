//
//  Formats.m
//  S5
//
//  Created by Dan Park on 6/8/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "Formats.h"

@implementation Formats

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString*)noLastCall
{
    return @"Call soon";
}

+ (NSString*)makeACall
{
    return @"Make a call";
}

+ (NSString*)stringInteger:(NSInteger)number
{
    return [NSString stringWithFormat:@"%d", number];
}

+ (NSString*)formatInteger:(NSInteger)number
{
	static NSNumberFormatter *numberFormatter;
	if (! numberFormatter) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //		[numberFormatter setMaximumFractionDigits:0];
	}
	
	NSString *string = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:number]];
    return string;
}

+ (NSString*)shortFormatMinuteUsage:(NSInteger)number
{
	NSString *string = [NSString stringWithFormat:@"%@ %@",
                        [self.class formatInteger:number],
                        [self.class shortMinutesUnit:number]
                        ];
    return string;
}


+ (NSString*)formatMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly isUnlimited:(BOOL)unlimited
{
	NSString *string = [NSString stringWithFormat:@"%@ / %@ %@",
                        [self.class formatInteger:number],
                        (unlimited) ? @"Unlimited" :    
                        [self.class formatInteger:monthly],
                        (unlimited) ? [NSString string] :
                        [self.class shortMinutesUnit:monthly]
                        ];
    return string;
}

+ (NSString*)formatNightMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly isUnlimited:(BOOL)unlimited
{
	NSString *string = [NSString stringWithFormat:@"%@ / %@ %@",
                        [self.class formatInteger:number],
                        (unlimited) ? @"Unlimited" :    
                        [self.class formatInteger:monthly],
                        (unlimited) ? [NSString string] :
                        [self.class shortMinutesUnit:monthly]
                        ];
    return string;
}

+ (NSString*)formatWeekendMinuteUsage:(NSInteger)number monthly:(NSInteger)monthly isUnlimited:(BOOL)unlimited
{
	NSString *string = [NSString stringWithFormat:@"%@ / %@ %@",
                        [self.class formatInteger:number],
                        (unlimited) ? @"Unlimited" :    
                        [self.class formatInteger:monthly],
                        (unlimited) ? [NSString string] :
                        [self.class shortMinutesUnit:monthly]
                        ];
    return string;
}


+ (NSString*)formatNumber:(NSNumber*)number
{
	static NSNumberFormatter *numberFormatter;
	if (! numberFormatter) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	
	NSString *string = [numberFormatter stringFromNumber:number];
    return string;
}

+ (NSString*)formatShortTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)formatMediumTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)formatNoDateTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)formatFullDateTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)formatShortTimeOnly:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)formatTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterLongStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)backgroundTimeRemaining
{
    NSString *formatedStatus = [NSString stringWithFormat:@"%@ %lf:BTR", 
                                [self formatTimestamp:[NSDate date]], 
                                [UIApplication sharedApplication].backgroundTimeRemaining];
    
    return formatedStatus;
}

+ (NSString*)daysUnitString:(NSInteger)days
{
    return (days > 1) ? NSLocalizedString(@"Days", nil) : NSLocalizedString(@"Day", nil);
}

+ (NSString*)daysLeftString:(NSInteger)days
{
    return [NSString stringWithFormat:@"%d %@ %@",
            days, [self.class daysUnitString:days], NSLocalizedString(@"Left", nil)];
}

+ (NSString*)relativeDaysLeftString:(NSInteger)days
{
    return [NSString stringWithFormat:@"%d %@ %@",
            days, [self.class daysUnitString:days], NSLocalizedString(@"Left", nil)];
}

+ (NSString*)hoursUnit:(NSInteger)number
{
//    return (number > 1) ? @"Hrs" : @"Hr";
    return (number > 1) ? NSLocalizedString(@"Hours", nil) : NSLocalizedString(@"Hour", nil);
}

+ (NSString*)minutesUnit:(NSInteger)number
{
//    return (number > 1) ? @"Mins" : @"Min";
    return (number > 1) ? NSLocalizedString(@"Minutes", nil) : NSLocalizedString(@"Minute", nil);
}

+ (NSString*)secondsUnit:(NSInteger)number
{
//    return (number > 1) ? @"Secs" : @"Sec";
    return (number > 1) ? NSLocalizedString(@"Seconds", nil) : NSLocalizedString(@"Second", nil);
}

+ (NSString*)shortHoursUnit:(NSInteger)number
{
    return (number > 1) ? @"Hrs" : @"Hr";
}

+ (NSString*)shortMinutesUnit:(NSInteger)number
{
    return (number > 1) ? @"Mins" : @"Min";
}

+ (NSString*)shortSecondsUnit:(NSInteger)number
{
    return (number > 1) ? @"Secs" : @"Sec";
}

+ (NSInteger)hoursUsed:(NSInteger)seconds
{
    NSInteger hours = seconds / 60.0 / 60.0;
    return hours;
}

+ (NSInteger)minutesUsed:(NSInteger)seconds
{
    NSInteger minutes = ceilf(seconds / 60.0);
    return minutes;
}





+ (NSString*)minsSeconds:(NSInteger)seconds
{
    NSInteger minutes = ceilf(seconds / 60.0);
    NSString *formatedUsage = [NSString stringWithFormat:@"%d %@ ( %@ %@ )", 
                               [self.class minutesUsed:seconds], 
                               [self.class minutesUnit:minutes],
                               [self.class formatInteger:seconds], 
                               [self.class secondsUnit:seconds]];
    return formatedUsage;
}

+ (NSString*)zeroNumberString:(NSInteger)number unit:(NSString*)unitString
{
    return (number > 0) 
    ? [NSString stringWithFormat:@"%d %@",number,unitString] 
    : [NSString string];
}

+ (NSString*)secondsInVariantUnit:(NSInteger)seconds
{
    NSString *variantUnit = [NSString stringWithFormat:@"%@", 
                   [self.class hoursMinsSeconds:seconds]];
    return variantUnit;
}


+ (NSString*)hoursMinsSeconds:(NSInteger)seconds shortForm:(BOOL)shortForm
{
    NSInteger hours = [self.class hoursUsed:seconds];
    NSInteger minutes = (seconds - (hours * 60 * 60)) / 60;
    NSInteger remainedSeconds = seconds - (hours * 60 * 60) - (minutes * 60);
    
    minutes += (remainedSeconds > 0) ? 1 : 0;
    if (minutes >= 60) {
        hours++;
        minutes -= 60;
    }
    NSString *hoursUnit;
    NSString *minutesUnit;

    if (shortForm) {
        hoursUnit = [self.class shortHoursUnit:hours].lowercaseString;
        minutesUnit = [self.class shortMinutesUnit:minutes].lowercaseString;
    } else {
        hoursUnit = [self.class hoursUnit:hours];
        minutesUnit = [self.class minutesUnit:minutes];
    }
    
    
    
    NSString *formatedUsage = [NSString stringWithFormat:@"%@ %@", 
                               [self.class zeroNumberString:hours unit:hoursUnit], 
                               [self.class zeroNumberString:minutes unit:minutesUnit]];
    return formatedUsage;
}

+ (NSString*)hoursMinsSeconds:(NSInteger)seconds
{
    BOOL shortForm = NO;
    return [self hoursMinsSeconds:seconds shortForm:shortForm];
}

+ (NSString*)daysHoursMins:(NSInteger)minutes
{
    NSInteger days = minutes / 60.0 / 24.0;
    NSInteger hours = (minutes - (days * 24 * 60)) / 60.0;
    NSInteger remainedMinutes = minutes - (days * 24 * 60) - (hours * 60);
    
    NSString *formatedUsage = [NSString stringWithFormat:@"%@ %@ %@", 
                               [self.class zeroNumberString:days unit:[self.class daysUnitString:days]], 
                               [self.class zeroNumberString:hours unit:[self.class shortHoursUnit:hours]], 
                               [self.class zeroNumberString:remainedMinutes unit:[self.class shortMinutesUnit:remainedMinutes]]];
    return formatedUsage;
}
+ (NSString*)trueMinsSeconds:(NSInteger)seconds
{
    NSInteger minutes = seconds / 60.0;
    NSInteger remainedSeconds = seconds % 60;
    
    NSString *formatedUsage = [NSString stringWithFormat:@"%d %@, %d %@", 
                               minutes, 
                               [self.class minutesUnit:minutes],
                               remainedSeconds, 
                               [self.class secondsUnit:remainedSeconds]];
    return formatedUsage;
}

+ (NSString*)trueHoursMinsSeconds:(NSInteger)seconds
{
    NSInteger hours = [self.class hoursUsed:seconds];
    NSInteger minutes = (seconds - (hours * 60 * 60)) / 60;
    NSInteger remainedSeconds = seconds - (hours * 60 * 60) - (minutes * 60);
    
    
    NSString *formatedUsage = [NSString stringWithFormat:@"%@ %@ %@", 
                               [self.class zeroNumberString:hours unit:[self.class hoursUnit:hours]], 
                               [self.class zeroNumberString:minutes unit:[self.class minutesUnit:minutes]],
                               [self.class zeroNumberString:remainedSeconds unit:[self.class secondsUnit:remainedSeconds]]];
    return formatedUsage;
}
@end
