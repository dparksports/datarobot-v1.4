//
//  CallPeriod.m
//  S8
//
//  Created by Dan Park on 7/18/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "CallPeriod.h"
#import "UserDefaults.h"
#import "Formats.h"
#import "CalendarComponents.h"

@implementation CallPeriod

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark -
#pragma mark Night Period

+ (NSDateComponents*)nightStartTimeComponentsWithSeedTime:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger hour = [defaults integerForKey:WeekNightStartHour];
    NSInteger minutes = [defaults integerForKey:WeekNightStartMinutes];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;    
    NSDate *seedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:callTime];
    NSDateComponents *callTimeComponents = [calendar components:unitFlags fromDate:seedDate];
    
    
    callTimeComponents.hour = hour;
    callTimeComponents.minute = minutes;
    
    return callTimeComponents;
}

+ (NSDateComponents*)nightEndTimeComponentsWithSeedTime:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger endHour = [defaults integerForKey:WeekNightEndHour];
    NSInteger endMinutes = [defaults integerForKey:WeekNightEndMinutes];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;    
    NSDate *seedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:callTime];
    NSDateComponents *callTimeComponents = [calendar components:unitFlags fromDate:seedDate];
    
    
    callTimeComponents.hour = endHour;
    callTimeComponents.minute = endMinutes;
    
    return callTimeComponents;
}


+ (NSDate*)nightStartTimeDateWithSeedTime:(NSTimeInterval)callTime
{
    NSDateComponents *callTimeComponents = [self.class nightStartTimeComponentsWithSeedTime:callTime];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:callTimeComponents];
    return date;
}


+ (NSDate*)nightEndTimeDateWithSeedTime:(NSTimeInterval)callTime
{
    NSDateComponents *callTimeComponents = [self.class nightEndTimeComponentsWithSeedTime:callTime];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:callTimeComponents];
    return date;
}


+ (BOOL)isCallTimeAfterNightStartWeekday:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger weekNightStartDay = [defaults integerForKey:WeekNightStartDay];
    
    NSDateComponents *callTimeComponents = [CalendarComponents dateComponentsFromInterval:callTime];
    NSInteger callWeekday = [callTimeComponents weekday];
    if (0) {
        NSLog(@"%s:weekNightStartDay:%@", __FUNCTION__, [CalendarComponents weekdayString:weekNightStartDay]);
        NSLog(@"%s:callWeekday:%@", __FUNCTION__, [CalendarComponents weekdayString:callWeekday]);
    }
    
    if (weekNightStartDay <= callWeekday) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCallTimeBeforeNightEndWeekday:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger weekNightEndDay = [defaults integerForKey:WeekNightEndDay];
    
    NSDateComponents *callTimeComponents = [CalendarComponents dateComponentsFromInterval:callTime];
    NSInteger callWeekday = [callTimeComponents weekday];
    if (0) {
        NSLog(@"%s:weekNightEndDay:%@", __FUNCTION__, [CalendarComponents weekdayString:weekNightEndDay]);
        NSLog(@"%s:callWeekday:%@", __FUNCTION__, [CalendarComponents weekdayString:callWeekday]);
    }
    
    if (callWeekday <= weekNightEndDay ) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCallWithinNightTimeWindow:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger endHour = [defaults integerForKey:WeekNightEndHour];
    NSInteger endMinutes = [defaults integerForKey:WeekNightEndMinutes];
    NSInteger startHour = [defaults integerForKey:WeekNightStartHour];
    NSInteger startMinutes = [defaults integerForKey:WeekNightStartMinutes];
    
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;    
    NSDate *callDate = [NSDate dateWithTimeIntervalSinceReferenceDate:callTime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [calendar components:unitFlags fromDate:callDate];
    NSDateComponents *endComponents = [calendar components:unitFlags fromDate:callDate];
    NSDateComponents *callComponents = [calendar components:unitFlags fromDate:callDate];
    startComponents.hour = startHour;
    startComponents.minute = startMinutes;
    endComponents.hour = endHour;
    endComponents.minute = endMinutes;
    
    
    // 7/5 : end time 6th hour is larger than start time 21st hour
    if (startHour > endHour) 
    {
        if (callComponents.hour == endHour) 
        {
            if (callComponents.minute <= endMinutes) 
            {
                startComponents.day--;
            } 
            else 
            {
                // 7/7 : call time after 6am
                endComponents.day++;
            }
        } 
        else 
        {
            // 7/5 : call time before 6am
            if (callComponents.hour < endHour) 
            {
                startComponents.day--;
            } else {
                // 7/7 : call time after 6am
                endComponents.day++;
            }
        }
        
        
        // 7/7 : endHour anchor comparison is good enough;
        //     : below double add endComponent day.
        // 7/5 : call time after 9pm
        //        if (startHour <= callComponents.hour) {
        //            endComponents.day++;
        //        }
        
        if (0) {
            NSLog(@"%s:incrementing endComponent Day: startHour:%d > endHour:%d", 
                  __FUNCTION__, startHour, endHour);
        }
    }
    
    NSDate *startDate = [calendar dateFromComponents:startComponents];
    NSDate *endDate = [calendar dateFromComponents:endComponents];
    
    // 7/7 : startTime <= callTime <= endTime (inclusive start time & end time)
    //     : why do we need non-inclusive endTime?
    BOOL afterStartTime = [startDate timeIntervalSinceReferenceDate] <= callTime;
    BOOL beforeEndTime = callTime <= [endDate timeIntervalSinceReferenceDate] ;
    
    if (0) {
        NSLog(@"%s", __FUNCTION__);
        NSLog(@"%s:callTime:%@", __FUNCTION__, 
              [CalendarComponents dateStringFromInterval:callTime]);
        NSLog(@"%s:startDate:%@", __FUNCTION__, 
              [CalendarComponents dateStringFromInterval:[startDate timeIntervalSinceReferenceDate]]);
        NSLog(@"%s:endDate:%@", __FUNCTION__, 
              [CalendarComponents dateStringFromInterval:[endDate timeIntervalSinceReferenceDate]]);
    }
    
    
    return afterStartTime && beforeEndTime;
}

+ (BOOL)areStartAndEndTimesInNightHours:(NSTimeInterval)callStartTime callEndTime:(NSTimeInterval)callEndTime
{
    BOOL calledAfterNightStartWeekDay = [self.class isCallTimeAfterNightStartWeekday:callStartTime];
    BOOL calledBeforeNightEndWeekDay = [self.class isCallTimeBeforeNightEndWeekday:callEndTime];
    if (calledAfterNightStartWeekDay && calledBeforeNightEndWeekDay) 
    {
        BOOL within = [self.class isCallWithinNightTimeWindow:callStartTime]
        && [self.class isCallWithinNightTimeWindow:callEndTime];
        return within;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Weekend Period



+ (NSDateComponents*)endDateComponentsWithSeedTime:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger endHour = [defaults integerForKey:WeekendEndHour];
    NSInteger endMinutes = [defaults integerForKey:WeekendEndMinutes];
    NSInteger endWeekDay = [defaults integerForKey:WeekendEndDay];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;    
    NSDate *seedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:callTime];
    NSDateComponents *callTimeComponents = [calendar components:unitFlags fromDate:seedDate];
    
    
    callTimeComponents.hour = endHour;
    callTimeComponents.minute = endMinutes;
    
    if (endWeekDay != callTimeComponents.weekday) 
    {
        if (callTimeComponents.weekday < endWeekDay) 
        {
            NSInteger diffDays = endWeekDay - callTimeComponents.weekday;
            callTimeComponents.day += diffDays;
        } 
        
        if (endWeekDay < callTimeComponents.weekday ) 
        {
            endWeekDay += 7;
            NSInteger diffDays = endWeekDay - callTimeComponents.weekday;
            callTimeComponents.day += diffDays;
        }
    }
    
    return callTimeComponents;
}

+ (NSDate*)startWeekendDateWithSeedTime:(NSTimeInterval)callTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger startHour = [defaults integerForKey:WeekendStartHour];
    NSInteger startMinutes = [defaults integerForKey:WeekendStartMinutes];
    NSInteger startWeekDay = [defaults integerForKey:WeekendStartDay];
    NSInteger endWeekDay = [defaults integerForKey:WeekendEndDay];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *endWeekDayComponents = [self.class endDateComponentsWithSeedTime:callTime];
    if (endWeekDay < startWeekDay) {
        endWeekDay += 7;
    }
    NSInteger numberOfWeekendDays = endWeekDay - startWeekDay;
    endWeekDayComponents.day -= numberOfWeekendDays;
    
    
    endWeekDayComponents.hour = startHour;
    endWeekDayComponents.minute = startMinutes;
    
    NSDate *startDate = [calendar dateFromComponents:endWeekDayComponents];
    return startDate;
}

+ (NSDate*)endWeekendDateWithSeedTime:(NSTimeInterval)callTime
{
    NSDateComponents *callTimeComponents = [self.class endDateComponentsWithSeedTime:callTime];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateFromComponents:callTimeComponents];
    return startDate;
}

+ (BOOL)isCallTimeAfterWeekendStartTime:(NSTimeInterval)callTime
{
    NSDate *startDate = [self.class startWeekendDateWithSeedTime:callTime];
    NSTimeInterval startInterval = [startDate timeIntervalSinceReferenceDate];
    
    if (0) {
        NSLog(@"%s:startDate:%@", __FUNCTION__, 
              [Formats formatMediumTimestamp:startDate]);
        NSLog(@"%s:callTime:%@", __FUNCTION__, 
              [Formats formatMediumTimestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:callTime]]);
    }
    
    if (startInterval <= callTime) 
    {
        return YES;
    }
    return NO;    
}

+ (BOOL)isCallTimeBeforeWeekendEndTime:(NSTimeInterval)callTime
{
    NSDate *endDate = [self.class endWeekendDateWithSeedTime:callTime];
    NSTimeInterval endInterval = [endDate timeIntervalSinceReferenceDate];
    
    if (0) {
        NSLog(@"%s:endDate:%@", __FUNCTION__, 
              [Formats formatMediumTimestamp:endDate]);
        NSLog(@"%s:callTime:%@", __FUNCTION__, 
              [Formats formatMediumTimestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:callTime]]);
    }
    
    if (callTime <= endInterval) 
    {
        return YES;
    }
    return NO;    
}


+ (BOOL)isCallWithinWeekendTimeWindow:(NSTimeInterval)callTime
{
    BOOL calledAfterWeekendStartTime = [self.class isCallTimeAfterWeekendStartTime:callTime];
    BOOL calledBeforeWeekendEndTime = [self.class isCallTimeBeforeWeekendEndTime:callTime];
    
    return calledAfterWeekendStartTime && calledBeforeWeekendEndTime;
}


@end


