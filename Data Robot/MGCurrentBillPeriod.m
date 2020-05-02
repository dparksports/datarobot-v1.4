//
//  MGCurrentBillPeriod.m
//  Data Robot
//
//  Created by Dan Park on 6/9/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGCurrentBillPeriod.h"

@interface MGCurrentBillPeriod ()
@end


@implementation MGCurrentBillPeriod

#define SAVED_LAST_ANCHOR_DATE @"savedLastAnchoredDate"
#define SAVED_DAY_OF_LAST_ANCHOR @"savedDayOfLastAnchor"
#define SAVED_MONTH_OF_LAST_ANCHOR @"savedMonthOfLastAnchor"
#define SAVED_YEAR_OF_LAST_ANCHOR @"savedYearOfLastAnchor"

#define SAVED_ADJUSTED_DATA_USAGE_NAME @"adjustedDataUsageInMB"
#define SAVED_DATA_QUOTA_NAME @"dataQuotaInMB"
#define NEW_BILL_DAY_OF_MONTH_NAME @"newBillDayOfMonth"

- (id) initWithCoder: (NSCoder *)coder
{
    self = [self init];
    if (self != nil) {
        self.lastAnchoredDate = [coder decodeObjectForKey: SAVED_LAST_ANCHOR_DATE];
//        self.dayOfLastAnchor = [coder decodeObjectForKey: SAVED_DAY_OF_LAST_ANCHOR];
//        self.monthOfLastAnchor = [coder decodeObjectForKey: SAVED_MONTH_OF_LAST_ANCHOR];
//        self.yearOfLastAnchor = [coder decodeObjectForKey: SAVED_YEAR_OF_LAST_ANCHOR];
        self.billDayOfMonth = [coder decodeObjectForKey: NEW_BILL_DAY_OF_MONTH_NAME];
        self.adjustedDataUsageInMB = [coder decodeObjectForKey: SAVED_ADJUSTED_DATA_USAGE_NAME];
        self.dataQuotaInMB = [coder decodeObjectForKey: SAVED_DATA_QUOTA_NAME];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: _lastAnchoredDate forKey: SAVED_LAST_ANCHOR_DATE];
//    [coder encodeObject: _dayOfLastAnchor forKey: SAVED_DAY_OF_LAST_ANCHOR];
//    [coder encodeObject: _monthOfLastAnchor forKey: SAVED_MONTH_OF_LAST_ANCHOR];
//    [coder encodeObject: _yearOfLastAnchor forKey: SAVED_YEAR_OF_LAST_ANCHOR];
    [coder encodeObject: _billDayOfMonth forKey: NEW_BILL_DAY_OF_MONTH_NAME];
    [coder encodeObject: _adjustedDataUsageInMB forKey: SAVED_ADJUSTED_DATA_USAGE_NAME];
    [coder encodeObject: _dataQuotaInMB forKey: SAVED_DATA_QUOTA_NAME];
}

//- (NSInteger)dayInToday
//{
//#ifdef DEBUG0
//    NSLog(@"%s", __FUNCTION__);
//#endif
//    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
//    NSString *gregorianType = NSGregorianCalendar;
//    NSDate *today = [NSDate date];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:gregorianType];
//    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
//    NSInteger day = [components day];
//    return day;
//}

//- (NSDate*)lastAnchoredDateFromBillRecord
//{
//    NSDateComponents *emptyComponents = [[NSDateComponents alloc] init];
//    emptyComponents.year = [self.yearOfLastAnchor integerValue];
//    emptyComponents.month = [self.monthOfLastAnchor integerValue];
//    emptyComponents.day = [self.dayOfLastAnchor integerValue];
//    
//    // Need a uniform calendar comparison by using Gregorian calendar everywhere.
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDate *currentMonthDate = [calendar dateFromComponents:emptyComponents];
//    return currentMonthDate;
//}

+ (NSDateComponents*)currentDataComponents
{
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDate *today = [NSDate date];
    NSString *gregorianType = NSGregorianCalendar;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:gregorianType];
    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
    return components;
}

+ (NSInteger)yearOfToday
{
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    NSDateComponents *components = [[self class] currentDataComponents];
    NSInteger month = [components year];
    return month;
}

+ (NSInteger)monthOfToday
{
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    NSDateComponents *components = [[self class] currentDataComponents];
    NSInteger month = [components month];
    return month;
}

+ (NSInteger)dayOfToday {
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    NSDateComponents *components = [[self class] currentDataComponents];
    NSInteger day = [components day];
    return day;
}

- (NSDate*)lastAnchoredDateFromBillRecord
{
    return self.lastAnchoredDate;
}

- (NSDate*)resetDateOfThisMonth
{
    NSInteger billDayOfMonth = [self.billDayOfMonth integerValue];
    NSDateComponents *emptyComponents = [[NSDateComponents alloc] init];
    emptyComponents.year = [[self class] yearOfToday];
    emptyComponents.month = [[self class] monthOfToday];
    emptyComponents.day = billDayOfMonth;
    
    // Need a uniform calendar comparison by using Gregorian calendar everywhere.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *billDayFromThisMonth = [calendar dateFromComponents:emptyComponents];
    return billDayFromThisMonth;
}

- (NSDate*)resetDateOfNextMonth
{
    // Need a uniform calendar comparison by using Gregorian calendar everywhere.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nextMonthComponents = [[NSDateComponents alloc] init];
    nextMonthComponents.month = 1;
    
    NSDate *billDayFromThisMonth = [self resetDateOfThisMonth];
    NSDate *billDayFromNextMonth = [calendar dateByAddingComponents:nextMonthComponents
                                                      toDate:billDayFromThisMonth
                                                     options:0];
    return billDayFromNextMonth;
}

// deprecated; saved for reference
- (NSDate*)resetDateOfThisOrNextMonth
{
    NSInteger dayInToday = [[self class] dayOfToday];
    NSInteger resetDay = [self.billDayOfMonth integerValue];
    NSDate *billDayFromThisMonth = [self resetDateOfThisMonth];
    if (dayInToday < resetDay ) {
        return billDayFromThisMonth;
    }
    
    // Need a uniform calendar comparison by using Gregorian calendar everywhere.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nextMonthComponents = [[NSDateComponents alloc] init];
    nextMonthComponents.month = 1;
    NSDate *billDayFromNextMonth = [calendar dateByAddingComponents:nextMonthComponents
                                                             toDate:billDayFromThisMonth
                                                            options:0];
    return billDayFromNextMonth;
}

- (NSInteger)daysToReset
{
    NSInteger dayInToday = [[self class] dayOfToday];
    NSInteger resetDay = [self.billDayOfMonth integerValue];
    NSDate *billDayFromThisMonth = [self resetDateOfThisMonth];
    if (dayInToday < resetDay ) {
        NSInteger remainedDays = resetDay - dayInToday;
        return remainedDays;
    }
    
    // Need a uniform calendar comparison by using Gregorian calendar everywhere.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nextMonthComponents = [[NSDateComponents alloc] init];
    nextMonthComponents.month = 1;
    NSDate *billDayFromNextMonth = [calendar dateByAddingComponents:nextMonthComponents
                                                             toDate:billDayFromThisMonth
                                                            options:0];
    
    NSDate *today = [NSDate date];
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *diffComponents = [calendar components:unitFlags
                                                   fromDate:today
                                                     toDate:billDayFromNextMonth
                                                    options:0];
    
    NSInteger days = [diffComponents day];
    return days;
}

@end
