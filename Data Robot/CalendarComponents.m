//  Created & Updated by Dan Park from 5/23/11 to 6/3/11
//

#import "CalendarComponents.h"
#import "UserDefaults.h"
#import "Formats.h"

@implementation CalendarComponents

+ (NSString*)todayDateLongString
{
    NSDate *today = [NSDate date];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    return [dateFormatter stringFromDate:today];
}

+ (NSArray*)monthSymbols
{
    static NSArray *monthSymbols = nil;
    if (!monthSymbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        monthSymbols = [formatter monthSymbols];
    }
    
    return monthSymbols;
}

+ (NSArray*)shortMonthSymbols
{
    static NSArray *monthSymbols = nil;
    if (!monthSymbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        monthSymbols = [formatter shortMonthSymbols];
    }
    return monthSymbols;
}

+ (NSArray*)weekdaySymbols
{
    static NSArray *symbols = nil;
    if (!symbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        symbols = [formatter weekdaySymbols];
    }
    return symbols;
}

+ (NSArray*)shortWeekdaySymbols
{
    static NSArray *symbols = nil;
    if (!symbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        symbols = [formatter shortWeekdaySymbols];
    }
    return symbols;
}

+ (NSDate*)dateFromComponents:(NSDateComponents*)dateComponents
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *calendarDate = [calendar dateFromComponents:dateComponents];
    return calendarDate;
}

+ (NSDate*)calendarDateFromInterval:(NSTimeInterval)interval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 6/22 : commented since we are still comparing absolute time of NSDate.
    //    // 6/22 : systemTimeZone may be changed by the user.
    //    //      : otherwise it's automatically changed by the device.
    //    
    //    NSTimeZone *deviceTimeZone = [NSTimeZone systemTimeZone];
    //    calendar.timeZone = deviceTimeZone;
    
    NSDate *absoluteDate = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
    
    NSDateComponents *emptycomponents = [[NSDateComponents alloc] init];
    
    NSDate *calendarDate = [calendar dateByAddingComponents:emptycomponents toDate:absoluteDate options:0];
    return calendarDate;
}

+ (NSString*)dateStringFromInterval:(NSTimeInterval)interval
{
    NSDate *absoluteDate = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
    NSString *dateString = [Formats formatMediumTimestamp:absoluteDate];
    return dateString;
}

+ (NSDateComponents*)dateComponentsFromInterval:(NSTimeInterval)interval
{
    
    // 6/22 : commented since we are still comparing absolute time of NSDate.
//    // 6/22 : systemTimeZone may be changed by the user.
//    //      : otherwise it's automatically changed by the device.
//    
//    NSTimeZone *deviceTimeZone = [NSTimeZone systemTimeZone];
//    calendar.timeZone = deviceTimeZone;
    
    
    NSDate *date = [self.class calendarDateFromInterval:interval];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    return components;
}

#pragma mark Night Night Start & End Times








// 7/5 : works for night end time being before or after noon.
//     : must be week night days.

// 7/5 : night end time can be before or after noon.
//     : if night end time is after noon, timeinterval comparison doesn't work.


//+ (BOOL)isCallTimeBeforeNightEndTime:(NSTimeInterval)callTime
//{
//    NSDateComponents *callComponents = [self.class dateComponentsFromInterval:callTime];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSInteger weekNightStartHour = [defaults integerForKey:WeekNightStartHour];
//    NSInteger weekNightEndHour = [defaults integerForKey:WeekNightEndHour];
//    NSInteger weekNightEndMinutes = [defaults integerForKey:WeekNightEndMinutes];
//    if (0) {
//        NSLog(@"%s:callComponents.hour:%d, weekNightEndHour:%d, ", 
//              __FUNCTION__, callComponents.hour, weekNightEndHour);
//        NSLog(@"%s:callComponents.minute:%d, weekNightEndMinutes:%d, ", 
//              __FUNCTION__, callComponents.minute, weekNightEndMinutes);
//    }
//    
//    // 7/5 : normalize end hour in the same unit, if night start hour is larger than end hour.
//    //     : shift night end hour to 12am.(0 am but 24th hour is fine for computation).
//    if (weekNightStartHour > weekNightEndHour) 
//    {
//        callComponents.hour -= weekNightEndHour;
//        weekNightEndHour = 24;
//        
//        if (0) {
//            NSLog(@"%s:normalized:callComponents.hour:%d, weekNightEndHour:%d, ", 
//                  __FUNCTION__, callComponents.hour, weekNightEndHour);
//            NSLog(@"%s:normalized:callComponents.minute:%d, weekNightEndMinutes:%d, ", 
//                  __FUNCTION__, callComponents.minute, weekNightEndMinutes);
//        }
//    }
//    
//    // 7/5 : minute usage not inclusive of the night end minute
//    if (callComponents.hour == weekNightEndHour
//        && callComponents.minute < weekNightEndMinutes) 
//    {
//        return YES;
//    }
//    if (callComponents.hour < weekNightEndHour) 
//    {
//        return YES;
//    }
//    return NO;
//}

#pragma mark Night Night Weekday



+ (BOOL)isCallTimeWithinNightHours:(NSTimeInterval)callTime
{
    NSDateComponents *callComponents = [self.class dateComponentsFromInterval:callTime];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (12 < callComponents.hour) 
    {
        // 6/27 : after noon, compare callTime with night start time.
        NSInteger weekNightStartHour = [defaults integerForKey:WeekNightStartHour];
        NSInteger weekNightStartMinutes = [defaults integerForKey:WeekNightStartMinutes];
#ifdef DEBUG
        NSLog(@"%s:callComponents.hour:%d, weekNightStartHour:%d, ",
              __FUNCTION__, callComponents.hour, weekNightStartHour);
        NSLog(@"%s:callComponents.minute:%d, weekNightStartMinutes:%d, ",
              __FUNCTION__, callComponents.minute, weekNightStartMinutes);
#endif
        if (weekNightStartHour == callComponents.hour
            && weekNightStartMinutes <= callComponents.minute) 
        {
            return YES;
        }
        if (weekNightStartHour < callComponents.hour) 
        {
            return YES;
        } 
        return NO;
    } 
    else 
    {
        // 6/27 : before noon, compare callTime with night end time.
        NSInteger weekNightEndHour = [defaults integerForKey:WeekNightEndHour];
        NSInteger weekNightEndMinutes = [defaults integerForKey:WeekNightEndMinutes];
#ifdef DEBUG
        NSLog(@"%s:callComponents.hour:%d, weekNightEndHour:%d, ",
              __FUNCTION__, callComponents.hour, weekNightEndHour);
        NSLog(@"%s:callComponents.minute:%d, weekNightEndMinutes:%d, ",
              __FUNCTION__, callComponents.minute, weekNightEndMinutes);
#endif
        
        if (callComponents.hour == weekNightEndHour
            && callComponents.minute <= weekNightEndMinutes) 
        {
            return YES;
        }
        if (callComponents.hour < weekNightEndHour) 
        {
            return YES;
        }
        return NO;
    }
}

// 7/5 : works for night start end being before or after noon.
//     : must be week night days.
+ (BOOL)isCallTimeAfterNightStartTime:(NSTimeInterval)callTime
{
    NSDateComponents *callComponents = [self.class dateComponentsFromInterval:callTime];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger weekNightStartHour = [defaults integerForKey:WeekNightStartHour];
    NSInteger weekNightEndHour = [defaults integerForKey:WeekNightEndHour];
    NSInteger weekNightStartMinutes = [defaults integerForKey:WeekNightStartMinutes];
#ifdef DEBUG
    NSLog(@"%s:callComponents.hour:%d, weekNightStartHour:%d, ",
          __FUNCTION__, callComponents.hour, weekNightStartHour);
    NSLog(@"%s:callComponents.minute:%d, weekNightStartMinutes:%d, ",
          __FUNCTION__, callComponents.minute, weekNightStartMinutes);
#endif
    
    // 7/5 : normalize end hour in the same unit, if night start hour is larger than end hour.
    //     : shift night end hour to 12am.(0 am but 24th hour is fine for computation).
    if (weekNightStartHour > weekNightEndHour) 
    {
        callComponents.hour -= weekNightEndHour;
        weekNightStartHour -= weekNightEndHour;
        weekNightEndHour = 24;
#ifdef DEBUG
        NSLog(@"%s:normalized:callComponents.hour:%d, weekNightStartHour:%d, weekNightEndHour:%d",
              __FUNCTION__, callComponents.hour, weekNightStartHour, weekNightEndHour);
#endif
    }
    
    if (weekNightStartHour == callComponents.hour
        && weekNightStartMinutes <= callComponents.minute) 
    {
        return YES;
    }
    if (weekNightStartHour < callComponents.hour) 
    {
        return YES;
    } 
    return NO;
}



//+ (BOOL)isCallWithinNightTimeWindow:(NSTimeInterval)startTime end:(NSTimeInterval)endTime
//{
//    BOOL calledAfterNightStartWeekDay = [self.class isCallTimeAfterNightStartWeekday:startTime];
//    if (! calledAfterNightStartWeekDay) {
//        return NO;
//    }
//
//    BOOL calledBeforeNightEndWeekDay = [self.class isCallTimeBeforeNightEndWeekday:endTime];
//    if (! calledBeforeNightEndWeekDay) {
//        return NO;
//    }
//    
//    BOOL calledAfterNightStartTime = [self.class isCallTimeWithinNightHours:startTime];
//    if (! calledAfterNightStartTime) {
//        return NO;
//    }
//
//    BOOL calledAfterNightEndTime = [self.class isCallTimeWithinNightHours:endTime];
//    if (! calledAfterNightEndTime) {
//        return NO;
//    }
//    return YES;
//}


+ (NSDateComponents*)dateComponentsFromDate:(NSDate*)date
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    return components;
}

+ (NSDateComponents*)todayDateComponents
{
    NSDate *today = [NSDate date];
    NSDateComponents *dateComponents = [self.class dateComponentsFromDate:today];

    return dateComponents;
}

+ (NSDate*)givenSecondsFromNow:(NSInteger)seconds
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:today];
    
    dateComponents.second += seconds;
    NSDate *futureDate = [calendar dateFromComponents:dateComponents];
    return futureDate;
}

+ (NSDate*)tenSecondsFromNow
{
    return [self.class givenSecondsFromNow:20];
}


+ (NSInteger)currentYear
{
    NSDateComponents *todayDateComponents = [self.class todayDateComponents];
    return [todayDateComponents year];
}

+ (NSInteger)currentMonth
{
    NSDateComponents *todayDateComponents = [self.class todayDateComponents];
    return [todayDateComponents month];
}

+ (NSInteger)currentDay
{
    NSDateComponents *todayDateComponents = [self.class todayDateComponents];
    return [todayDateComponents day];
}

+ (NSInteger)currentWeekday
{
    NSDateComponents *todayDateComponents = [self.class todayDateComponents];
    return [todayDateComponents weekday];
}

+ (NSString*)shortWeekdayString:(NSInteger)weekday
{
    // 6/17 : weekday is 1-based index.
    NSArray *symbols = [self.class shortWeekdaySymbols];
    NSString *string = [NSString stringWithFormat:@"%@",
                        [symbols objectAtIndex:weekday - 1]];
    return string;
}

+ (NSString*)weekdayString:(NSInteger)weekday
{
    // 6/17 : weekday is 1-based index.
    NSArray *symbols = [self.class weekdaySymbols];
    NSString *string = [NSString stringWithFormat:@"%@",
                        [symbols objectAtIndex:weekday - 1]];
    return string;
}

+ (NSDate*)dateFromWeekday:(NSInteger)weekday 
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDate *today = [NSDate date];
    
    // 6/17 : Sunday is 1 in the Gregoarian calendar.
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
    components.weekday = weekday;
    
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

+ (NSDate*)dateFromHourMinutes:(NSInteger)hour minutes:(NSInteger)minute
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
    components.hour = hour;
    components.minute = minute;

    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

+ (NSDate*)nextDateFromHourMinutes:(NSInteger)hour minutes:(NSInteger)minute
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
    components.hour = hour;
    components.minute = minute;
    components.day += 1;
    
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

+ (NSDate*)dateFromHourMinuteWeekday:(NSInteger)hour minute:(NSInteger)minute weekday:(NSInteger)weekday
{
    NSDateComponents *components = [self.class todayDateComponents];
    
    NSDateComponents *emptyComponents = [[NSDateComponents alloc] init];
    emptyComponents.year = components.year;
    emptyComponents.month = components.month;
//    emptyComponents.day = components.day;
    emptyComponents.hour = hour;
    emptyComponents.minute = minute;
    emptyComponents.weekday = weekday;
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateFromComponents:emptyComponents];
    return newDate;
}

+ (NSDateComponents*)dateComponentsFromHourMinuteWeekdayWithCallTime:(NSInteger)hour minute:(NSInteger)minute weekday:(NSInteger)weekday with:(NSTimeInterval)callTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *seedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:callTime];
    NSDateComponents *callComponent = [calendar components:unitFlags fromDate:seedDate];
    return callComponent;
}

+ (NSDate*)calendarDateFromHourMinuteWeekday:(NSInteger)hour minute:(NSInteger)minute weekday:(NSInteger)weekday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 6/22 : commented since we are still comparing absolute time of NSDate.
    //    // 6/22 : systemTimeZone may be changed by the user.
    //    //      : otherwise it's automatically changed by the device.
    //    
    //    NSTimeZone *deviceTimeZone = [NSTimeZone systemTimeZone];
    //    calendar.timeZone = deviceTimeZone;

    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDate *today = [NSDate date];
    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
    components.hour = hour;
    components.minute = minute;

    
    NSDate *newDate = [calendar dateFromComponents:components];
    NSDateComponents *weekdayComponents = [[NSDateComponents alloc] init];
    
    // 6/24 : inclusive starting weekday.
    NSInteger diffWeekday = weekday - components.weekday;
    if (diffWeekday < 0) {
        diffWeekday += 7;
    }
    weekdayComponents.weekday = diffWeekday; 
    NSDate *weekdayDate = [calendar dateByAddingComponents:weekdayComponents toDate:newDate options:0];
    
    return weekdayDate;
}

+ (NSDate*)dateFromMonthDayYear:(NSInteger)month day:(NSInteger)day year:(NSInteger)year
{
    NSDateComponents *emptyComponents = [[NSDateComponents alloc] init];
    emptyComponents.year = [CalendarComponents currentYear];
    emptyComponents.month = [CalendarComponents currentMonth];
    emptyComponents.day = day;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:emptyComponents];
    return date;
}

+ (NSDateFormatter*)shortDateOnlyFormatter
{
    static NSDateFormatter *shortDateFormatter = nil;
    if (!shortDateFormatter) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return shortDateFormatter;
}

+ (NSDateFormatter*)relativeDateOnlyFormatter
{
    static NSDateFormatter *shortDateFormatter = nil;
    if (!shortDateFormatter) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
//        [shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [shortDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [shortDateFormatter setDoesRelativeDateFormatting:YES];
    }
    
    return shortDateFormatter;
}

+ (NSDateFormatter*)mediumDateOnlyFormatter
{
    static NSDateFormatter *shortDateFormatter = nil;
    if (!shortDateFormatter) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [shortDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    return shortDateFormatter;
}

+ (NSDateFormatter*)fullDateOnlyFormatter
{
    static NSDateFormatter *shortDateFormatter = nil;
    if (!shortDateFormatter) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [shortDateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    return shortDateFormatter;
}

+ (NSDate*)dateFromNextMonthDay:(NSInteger)day
{
    NSInteger month = [CalendarComponents currentMonth];
    NSInteger year = [CalendarComponents currentYear];
    NSDate *currentMonthDate = [self.class dateFromMonthDayYear:month day:day year:year];

    
    NSDateComponents *nextMonthComponents = [[NSDateComponents alloc] init];
    nextMonthComponents.month = 1;

    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *nextMonthDate = [calendar dateByAddingComponents:nextMonthComponents toDate:currentMonthDate options:0];
    return nextMonthDate;
}

+ (NSDate*)dateFromNextMonthDayIfPassed:(NSInteger)day
{
    NSInteger month = [CalendarComponents currentMonth];
    NSInteger year = [CalendarComponents currentYear];
    NSDate *currentMonthDate = [self.class dateFromMonthDayYear:month day:day year:year];
    if (day > [CalendarComponents currentDay]) {
        return currentMonthDate;
    } 

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nextMonthComponents = [[NSDateComponents alloc] init];
    nextMonthComponents.month = 1;
    
    NSDate *nextMonthDate = [calendar dateByAddingComponents:nextMonthComponents toDate:currentMonthDate options:0];
    return nextMonthDate;
}

+ (NSInteger)daysFromTodayToNextMonthDay:(NSInteger)day
{
    NSDate *today = [NSDate date];
    NSDate *nextMonthDate = [self.class dateFromNextMonthDayIfPassed:day];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *diffComponents = [calendar components:unitFlags fromDate:today toDate:nextMonthDate options:0];
    
    NSInteger days = [diffComponents day];
#ifdef DEBUG
    NSLog(@"%s:today:%@", __FUNCTION__, [[self.class shortDateOnlyFormatter] stringFromDate:today]);
    NSLog(@"%s:nextMonthDate:%@", __FUNCTION__, [[self.class shortDateOnlyFormatter] stringFromDate:nextMonthDate]);
    NSLog(@"%s:days:%d", __FUNCTION__, days);
#endif
    return days;
}

+ (NSInteger)daysNextMonthDay:(NSInteger)day
{
    NSDate *today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *newComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];

    if (day <= [newComponents day]) {
        newComponents.month++;
    }
    newComponents.day = day;
    
    
    NSDate *newDate = [calendar dateFromComponents:newComponents];

    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *diffComponents = [calendar components:unitFlags fromDate:today toDate:newDate options:kCFCalendarComponentsWrap];
    
    NSInteger days = [diffComponents day] + 1;//inclusive today
#ifdef DEBUG
    NSLog(@"%s:today:%@", __FUNCTION__, [[self.class shortDateOnlyFormatter] stringFromDate:today]);
    NSLog(@"%s:newDate:%@", __FUNCTION__, [[self.class shortDateOnlyFormatter] stringFromDate:newDate]);
    NSLog(@"%s:days:%d", __FUNCTION__, days);
#endif
    return days;
}

+ (NSInteger)isSameDay:(NSDate*)firstDate second:(NSDate*)secondDate
{
    NSDateComponents *firstComponents = [self.class dateComponentsFromDate:firstDate];
    NSDateComponents *secondComponents = [self.class dateComponentsFromDate:secondDate];
    
    return firstComponents.day == secondComponents.day;
}

+ (NSString*)shortDateStringFromNextMonthDay:(NSInteger)day
{
    NSDate *date = [self.class dateFromNextMonthDay:day];
    NSDateFormatter *formatter = [self.class shortDateOnlyFormatter];
    NSString *string = [formatter stringFromDate:date];
    
    return string;
}

+ (NSString*)mediumDateStringFromNextMonthDay:(NSInteger)day
{
    NSDate *date = [self.class dateFromNextMonthDay:day];
    NSDateFormatter *formatter = [self.class mediumDateOnlyFormatter];
    
    NSString *string = [formatter stringFromDate:date];
    
    return string;
}

+ (NSString*)mediumDateStringFromNextMonthDayIfPassed:(NSInteger)day
{
    NSDate *date = [self.class dateFromNextMonthDayIfPassed:day];
    NSDateFormatter *formatter = [self.class mediumDateOnlyFormatter];
    
    NSString *string = [formatter stringFromDate:date];
    
    return string;
}

+ (NSString*)fullDateStringFromNextMonthDayIfPassed:(NSInteger)day
{
    NSDate *date = [self.class dateFromNextMonthDayIfPassed:day];
    NSDateFormatter *formatter = [self.class fullDateOnlyFormatter];
    
    NSString *string = [formatter stringFromDate:date];
    
    return string;
}

+ (NSString*)relativeDateStringFromNextMonthDayIfPassed:(NSInteger)day
{
    NSDate *date = [self.class dateFromNextMonthDayIfPassed:day];
    NSDateFormatter *formatter = [self.class relativeDateOnlyFormatter];
    
    NSString *string = [formatter stringFromDate:date];
    
    return string;
}

+ (NSString*)fewRelativeDateStringFromNextMonthDayIfPassed:(NSInteger)day left:(NSInteger)daysLeft
{
    if (2 >= daysLeft) 
    {
        return [self.class relativeDateStringFromNextMonthDayIfPassed:day];
    } 
    else 
    {
        return [self.class fullDateStringFromNextMonthDayIfPassed:day];
    }
}

+ (NSString*)resetsShortRelativeDateStringFromNextMonthDayIfPassed:(NSInteger)day left:(NSInteger)daysLeft
{
    NSString *myMinutesString;
    if (0) {
        myMinutesString = [NSString stringWithFormat:@"My minutes resets"];
    } else {
        myMinutesString = [NSString stringWithFormat:@"Resets"];
    }
    
    if (2 >= daysLeft) 
    {
        return [NSString stringWithFormat:@"%@ on %@",
                myMinutesString,
                [self.class fewRelativeDateStringFromNextMonthDayIfPassed:day left:daysLeft]];
    } else 
    {
        return [NSString stringWithFormat:@"%@ on %@",
                myMinutesString,
                [self.class fewRelativeDateStringFromNextMonthDayIfPassed:day left:daysLeft]];
    }
}

+ (NSString*)shortWeekday:(NSInteger)month day:(NSInteger)day year:(NSInteger)year
{
    NSDate *date = [self.class dateFromMonthDayYear:month day:day year:year];

    unsigned unitFlags = NSWeekdayCalendarUnit | NSYearCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger weekday = dateComponents.weekday;
    
    return [self.class shortWeekdayString:weekday];
}

+ (NSString*)currentWeekdayString
{
    NSInteger currentWeekday = [self.class currentWeekday];
    return [self.class weekdayString:currentWeekday];
}

+ (NSString*)shortMonthString:(NSInteger)month
{
    NSArray *monthSymbols = [self.class shortMonthSymbols];
    
    if (month > [monthSymbols count]) {
        month = [monthSymbols count];
    }
    NSString *dayString = [NSString stringWithFormat:@"%@",
                           [monthSymbols objectAtIndex:month - 1]];
    return dayString;
}

+ (NSString*)currentMonthString
{
    NSInteger currentMonth = [self.class currentMonth];
    return [self.class shortMonthString:currentMonth];
}



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
