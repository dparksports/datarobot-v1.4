//  Created & Updated by Dan Park from 5/23/11 to 6/3/11
//

#import <Foundation/Foundation.h>

@interface CalendarComponents : NSObject

+ (NSString*)todayDateLongString;

+ (NSArray*)monthSymbols;
+ (NSArray*)shortMonthSymbols;

+ (NSArray*)shortWeekdaySymbols;
+ (NSArray*)weekdaySymbols;

+ (NSInteger)currentMonth;
+ (NSInteger)currentDay;
+ (NSInteger)currentYear;

+ (NSString*)shortMonthString:(NSInteger)month;
+ (NSString*)currentMonthString;

+ (NSString*)shortWeekdayString:(NSInteger)weekday;
+ (NSString*)weekdayString:(NSInteger)weekday;
+ (NSString*)currentWeekdayString;

+ (NSString*)shortWeekday:(NSInteger)month day:(NSInteger)day year:(NSInteger)year;

+ (NSDate*)dateFromHourMinuteWeekday:(NSInteger)hour minute:(NSInteger)minute weekday:(NSInteger)weekday;
+ (NSDate*)calendarDateFromHourMinuteWeekday:(NSInteger)hour minute:(NSInteger)minute weekday:(NSInteger)weekday;
+ (NSDate*)dateFromWeekday:(NSInteger)weekday;
+ (NSDate*)dateFromHourMinutes:(NSInteger)hour minutes:(NSInteger)minute;
+ (NSDate*)nextDateFromHourMinutes:(NSInteger)hour minutes:(NSInteger)minute;
+ (NSDate*)dateFromMonthDayYear:(NSInteger)month day:(NSInteger)day year:(NSInteger)year;
+ (NSDate*)dateFromNextMonthDay:(NSInteger)day;
+ (NSDate*)dateFromNextMonthDayIfPassed:(NSInteger)day;


+ (NSDate*)calendarDateFromInterval:(NSTimeInterval)interval;
+ (NSString*)dateStringFromInterval:(NSTimeInterval)interval;

+ (NSDateComponents*)dateComponentsFromInterval:(NSTimeInterval)interval;
+ (NSDateComponents*)dateComponentsFromDate:(NSDate*)date;
+ (NSDate*)dateFromComponents:(NSDateComponents*)dateComponents;
+ (NSDateComponents*)todayDateComponents;

+ (NSDate*)givenSecondsFromNow:(NSInteger)seconds;
+ (NSDate*)tenSecondsFromNow;

+ (NSString*)shortDateStringFromNextMonthDay:(NSInteger)day;
+ (NSString*)mediumDateStringFromNextMonthDay:(NSInteger)day;

+ (NSString*)mediumDateStringFromNextMonthDayIfPassed:(NSInteger)day;
+ (NSString*)fullDateStringFromNextMonthDayIfPassed:(NSInteger)day;

+ (NSString*)relativeDateStringFromNextMonthDayIfPassed:(NSInteger)day;
+ (NSString*)fewRelativeDateStringFromNextMonthDayIfPassed:(NSInteger)day left:(NSInteger)daysLeft;
//+ (NSString*)resetsRelativeDateStringFromNextMonthDayIfPassed:(NSInteger)day left:(NSInteger)daysLeft;
+ (NSString*)resetsShortRelativeDateStringFromNextMonthDayIfPassed:(NSInteger)day left:(NSInteger)daysLeft;

+ (NSInteger)daysFromTodayToNextMonthDay:(NSInteger)day;
+ (NSInteger)daysNextMonthDay:(NSInteger)day;
+ (NSInteger)isSameDay:(NSDate*)firstDate second:(NSDate*)secondDate;

@end
