//
//  CallPeriod.m
//  S6
//
//  Created by Dan Park on 7/6/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "CallPeriodStateMachine.h"

#import "UserDefaults.h"
#import "Formats.h"
#import "CalendarComponents.h"
#import "CallPeriod.h"

@implementation CallPeriodStateMachine
@synthesize lastCallSeconds;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+ (NSString*)callPeriod:(NSInteger)period
{
    NSString *periodString;
    switch (period) {
        case CallPeriodDay:
            periodString = @"Day";
            break;
        case CallPeriodNight:
            periodString = @"Night";
            break;
        case CallPeriodWeekend:
            periodString = @"Weekend";
            break;
        case CallPeriodRollover:
            periodString = @"Rollover";
            break;
        default:
            periodString = [NSString string];
            break;
    }
    
    return periodString;
}

static CallPeriodStateMachine *singleton = nil;
+ (CallPeriodStateMachine *)sharedInstance
{
    if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
#ifdef DEBUG
                          NSLog(@"%s:instantion", __FUNCTION__);
#endif
                          singleton = [[CallPeriodStateMachine alloc] init];
                      });
    }
    
//    if (!singleton) {
//        singleton = [[CallPeriodStateMachine alloc] init];
//        [singleton retain];
//    }
    return singleton;
}

- (void)saveWeekendMinutes:(NSInteger)usedSeconds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger weekendMinutesUsed = [defaults integerForKey:WeekendMinutesUsed];
    NSInteger nightWeekendMinutesUsed = [defaults integerForKey:NWMinutesUsed];
    
    weekendMinutesUsed += [Formats minutesUsed:usedSeconds];
    nightWeekendMinutesUsed += [Formats minutesUsed:usedSeconds];
    
    [defaults setInteger:weekendMinutesUsed forKey:WeekendMinutesUsed];
    [defaults setInteger:nightWeekendMinutesUsed forKey:NWMinutesUsed];
//    [defaults setInteger:CallPeriodWeekend forKey:LastCallPeriod];
    
#ifdef DEBUG
    NSLog(@"%s:usedSeconds:%d, weekendMinutesUsed:%d", __FUNCTION__, usedSeconds, weekendMinutesUsed);
    NSLog(@"%s:nightWeekendMinutesUsed:%d", __FUNCTION__, nightWeekendMinutesUsed);
#endif
}

- (void)saveNightMinutes:(NSInteger)usedSeconds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger weekNightMinutesUsed = [defaults integerForKey:NightMinutesUsed];
    NSInteger nightWeekendMinutesUsed = [defaults integerForKey:NWMinutesUsed];
    
    weekNightMinutesUsed += [Formats minutesUsed:usedSeconds];
    nightWeekendMinutesUsed += [Formats minutesUsed:usedSeconds];
    
    [defaults setInteger:weekNightMinutesUsed forKey:NightMinutesUsed];
    [defaults setInteger:nightWeekendMinutesUsed forKey:NWMinutesUsed];
//    [defaults setInteger:CallPeriodNight forKey:LastCallPeriod];
    
#ifdef DEBUG
    NSLog(@"%s:usedSeconds:%d, weekNightMinutesUsed:%d", __FUNCTION__, usedSeconds, weekNightMinutesUsed);
    NSLog(@"%s:nightWeekendMinutesUsed:%d", __FUNCTION__, nightWeekendMinutesUsed);
#endif
}


- (void)saveDayMinutes:(NSInteger)usedSeconds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 11/10 : monthly allowance is DayMinutes, not Day Minutes Remained.
    NSInteger monthlyMinutesAllowance = [defaults integerForKey:DayMinutes];
    NSInteger monthlyMinutesUsed = [defaults integerForKey:DayMinutesUsed];

    
    monthlyMinutesUsed += [Formats minutesUsed:usedSeconds];
    [defaults setInteger:monthlyMinutesUsed forKey:DayMinutesUsed];
//    [defaults setInteger:CallPeriodDay forKey:LastCallPeriod];
    
#ifdef DEBUG
    NSLog(@"%s:usedSeconds:%d, monthlyMinutesUsed:%d, monthlyMinutesAllowance:%d", __FUNCTION__, usedSeconds, monthlyMinutesUsed, monthlyMinutesAllowance);
#endif
    
    BOOL enableRollover = [defaults boolForKey:EnableRollover];
    if (enableRollover) 
    {
        if (monthlyMinutesUsed >= monthlyMinutesAllowance) 
        {
            // 11/10 : Rollover Used = monthly used - monthly allowance.
            NSInteger rolloverMinutesUsed = monthlyMinutesUsed - monthlyMinutesAllowance;
            [defaults setInteger:rolloverMinutesUsed forKey:RolloverMinutesUsed];
            
            
            // 11/10 : Not resetting monthlyMinutesUsed
//            monthlyMinutesUsed = monthlyMinutesAllowance;
//            [defaults setInteger:monthlyMinutesUsed forKey:DayMinutesUsed];
            [defaults setInteger:CallPeriodRollover forKey:LastCallPeriod];
            
#ifdef DEBUG
            NSLog(@"%s:usedSeconds:%d, monthlyMinutesUsed:%d", __FUNCTION__, usedSeconds, monthlyMinutesUsed);
            NSLog(@"%s:rolloverMinutesUsed:%d", __FUNCTION__, rolloverMinutesUsed);
#endif
        } 
    } 
    
}

- (void)saveAdjustedCallTime:(NSInteger)callSeconds start:(NSTimeInterval)startTime end:(NSTimeInterval)endTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:callSeconds forKey:LastCallSecondsUsed];
    [defaults setDouble:startTime forKey:LastCallStartTime];
    [defaults setDouble:endTime forKey:LastCallEndTime];
    
    if (0) {
        NSLog(@"%s:callSeconds:%d", __FUNCTION__, callSeconds);
        NSLog(@"%s:startTime:%@", __FUNCTION__, [CalendarComponents dateStringFromInterval:startTime]);
        NSLog(@"%s:endTime:%@", __FUNCTION__, [CalendarComponents dateStringFromInterval:endTime]);
    }
}

- (void)saveSpillover:(NSInteger)spillSeconds start:(NSTimeInterval)startTime end:(NSTimeInterval)endTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:spillSeconds forKey:SpilloverSecondsUsed];
    [defaults setDouble:startTime forKey:SpilloverStartTime];
    [defaults setDouble:endTime forKey:SpilloverEndTime];
    
    if (0) {
        NSLog(@"%s:spillSeconds:%d", __FUNCTION__, spillSeconds);
        NSLog(@"%s:startTime:%@", __FUNCTION__, [CalendarComponents dateStringFromInterval:startTime]);
        NSLog(@"%s:endTime:%@", __FUNCTION__, [CalendarComponents dateStringFromInterval:endTime]);
    }
}


- (BOOL)updateWeekendMinutes:(NSInteger)usedSeconds start:(NSTimeInterval)callStartTime end:(NSTimeInterval)callEndTime
{
    BOOL calledAfterWeekendStartTime = [CallPeriod isCallTimeAfterWeekendStartTime:callStartTime];
    BOOL calledBeforeWeekendEndTime = [CallPeriod isCallTimeBeforeWeekendEndTime:callStartTime];
    
    if (calledAfterWeekendStartTime && calledBeforeWeekendEndTime) 
    {
        if ([CallPeriod isCallTimeBeforeWeekendEndTime:callEndTime]) 
        {
            [self saveWeekendMinutes:usedSeconds];
            if (0 == spillOverSeconds) {
                [self saveSpillover:0 start:0 end:0];
            }

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:CallPeriodWeekend forKey:LastCallPeriod];
            return YES;
        }
        else 
        {
            // 7/7 : compute spillover seconds.
            if (0 == spillOverSeconds) 
            {
                NSDate *endTimeDate = [CallPeriod endWeekendDateWithSeedTime:callEndTime];
                NSTimeInterval spillCallStartTime = [endTimeDate timeIntervalSinceReferenceDate];
                NSTimeInterval spillCallEndTime = callEndTime;
                
                spillOverSeconds = spillCallEndTime - spillCallStartTime;
                usedSeconds -= spillOverSeconds;
                
                [self saveWeekendMinutes:usedSeconds];
                [self saveAdjustedCallTime:usedSeconds start:callStartTime end:spillCallStartTime];
                [self saveSpillover:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];

                
                BOOL isNightPeriod = [self updateNightMinutes:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                if (isNightPeriod) 
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setInteger:CallPeriodNight forKey:SpilloverCallPeriod];
                    [defaults setInteger:CallPeriodWeekend forKey:LastCallPeriod];
                } 
                else 
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setInteger:CallPeriodDay forKey:SpilloverCallPeriod];
                    [defaults setInteger:CallPeriodWeekend forKey:LastCallPeriod];
                    
                    [self updateDayMinutes:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                }
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)updateNightMinutes:(NSInteger)usedSeconds start:(NSTimeInterval)callStartTime end:(NSTimeInterval)callEndTime
{
    BOOL calledAfterNightStartWeekDay = [CallPeriod isCallTimeAfterNightStartWeekday:callStartTime];
    BOOL calledBeforeNightEndWeekDay = [CallPeriod isCallTimeBeforeNightEndWeekday:callEndTime];
    if (calledAfterNightStartWeekDay && calledBeforeNightEndWeekDay) 
    {
        if ([CallPeriod isCallWithinNightTimeWindow:callStartTime]) 
        {
            if ([CallPeriod isCallWithinNightTimeWindow:callEndTime]) 
            {
                [self saveNightMinutes:usedSeconds];
                if (0 == spillOverSeconds) {
                    [self saveSpillover:0 start:0 end:0];
                }
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:CallPeriodNight forKey:LastCallPeriod];
                return YES;
            } 
            else 
            {
                if (0 == spillOverSeconds) 
                {
                    // 7/5 : Call End Time Spills over Night End Time
                    
                    NSDate *nightEndTimeDate = [CallPeriod nightEndTimeDateWithSeedTime:callEndTime];
                    NSTimeInterval spillCallStartTime = [nightEndTimeDate timeIntervalSinceReferenceDate];
                    NSTimeInterval spillCallEndTime = callEndTime;
                    
                    spillOverSeconds = spillCallEndTime - spillCallStartTime;
                    usedSeconds -= spillOverSeconds;
                    
                    [self saveNightMinutes:usedSeconds];
                    [self saveAdjustedCallTime:usedSeconds start:callStartTime end:spillCallStartTime];
                    [self saveSpillover:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                    
                    
                    BOOL isWeekendPeriod = [self updateWeekendMinutes:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                    if (isWeekendPeriod) 
                    {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setInteger:CallPeriodWeekend forKey:SpilloverCallPeriod];
                        [defaults setInteger:CallPeriodNight forKey:LastCallPeriod];
                    } 
                    else 
                    {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setInteger:CallPeriodDay forKey:SpilloverCallPeriod];
                        [defaults setInteger:CallPeriodNight forKey:LastCallPeriod];
                        [self updateDayMinutes:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                    }
                    return YES;
                }
            }
            
        }
    }
    
    return NO;
}

- (void)updateDayMinutes:(NSInteger)usedSeconds start:(NSTimeInterval)callStartTime end:(NSTimeInterval)callEndTime
{
    if (0) {
        NSLog(@"%s:callStartTime:%@", __FUNCTION__, [CalendarComponents dateStringFromInterval:callStartTime]);
        NSLog(@"%s:callEndTime:%@", __FUNCTION__, [CalendarComponents dateStringFromInterval:callEndTime]);
    }
    
    if (0 == spillOverSeconds) 
    {
        BOOL calledAfterNightStartWeekDay = [CallPeriod isCallTimeAfterNightStartWeekday:callEndTime];
        BOOL calledBeforeNightEndWeekDay = [CallPeriod isCallTimeBeforeNightEndWeekday:callEndTime];
        // 7/7 : save computed spillover seconds first, 
        //     : then substract it from usedSeconds before saving new usedSeconds.
        // 7/6 : compute spill seconds only when it's zero.
        if (calledAfterNightStartWeekDay && calledBeforeNightEndWeekDay) 
        {
            if ([CallPeriod isCallWithinNightTimeWindow:callEndTime]) 
            {
                NSDate *startTimeDate = [CallPeriod nightStartTimeDateWithSeedTime:callEndTime];
                NSTimeInterval spillCallStartTime = [startTimeDate timeIntervalSinceReferenceDate];
                NSTimeInterval spillCallEndTime = callEndTime;
                
                spillOverSeconds = spillCallEndTime - spillCallStartTime;
                usedSeconds -= spillOverSeconds;
                
                [self saveDayMinutes:usedSeconds];
                [self saveAdjustedCallTime:usedSeconds start:callStartTime end:spillCallStartTime];
                [self saveSpillover:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                [self saveNightMinutes:spillOverSeconds];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:CallPeriodNight forKey:SpilloverCallPeriod];
                [defaults setInteger:CallPeriodDay forKey:LastCallPeriod];
                return;
            }
        }
        else 
        {
            if ([CallPeriod isCallTimeAfterWeekendStartTime:callEndTime]) 
            {
                NSDate *startTimeDate = [CallPeriod startWeekendDateWithSeedTime:callEndTime];
                NSTimeInterval spillCallStartTime = [startTimeDate timeIntervalSinceReferenceDate];
                NSTimeInterval spillCallEndTime = callEndTime;
                
                spillOverSeconds = spillCallEndTime - spillCallStartTime;
                usedSeconds -= spillOverSeconds;
                
                [self saveDayMinutes:usedSeconds];
                [self saveAdjustedCallTime:usedSeconds start:callStartTime end:spillCallStartTime];
                [self saveSpillover:spillOverSeconds start:spillCallStartTime end:spillCallEndTime];
                [self saveWeekendMinutes:spillOverSeconds];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:CallPeriodWeekend forKey:SpilloverCallPeriod];
                [defaults setInteger:CallPeriodDay forKey:LastCallPeriod];
                return;
            }
        }
    }

    // 7/7 : includes both day period seconds & spill over seconds
    [self saveDayMinutes:usedSeconds];
    if (0 == spillOverSeconds) {
        [self saveSpillover:0 start:0 end:0];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:CallPeriodDay forKey:LastCallPeriod];
    }
}

- (void)updateDefaults:(NSInteger)usedSeconds lastCallStartTime:(NSTimeInterval)callStartTime lastCallEndTime:(NSTimeInterval)callEndTime
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:callStartTime forKey:LastCallStartTime];
    [defaults setDouble:callEndTime forKey:LastCallEndTime];
    [defaults setInteger:usedSeconds forKey:LastCallSecondsUsed];
    
    NSInteger lifeMinutesUsed = [defaults integerForKey:LifeMinutesUsed];
    lifeMinutesUsed += [Formats minutesUsed:usedSeconds];
    [defaults setInteger:lifeMinutesUsed forKey:LifeMinutesUsed];

    spillOverSeconds = 0;
    BOOL isNightPeriod = [self updateNightMinutes:usedSeconds start:callStartTime end:callEndTime];
    if (! isNightPeriod) 
    {
        BOOL isWeekendPeriod = [self updateWeekendMinutes:usedSeconds start:callStartTime end:callEndTime];
        if (! isWeekendPeriod) 
        {
            [self updateDayMinutes:usedSeconds start:callStartTime end:callEndTime];
        }
    }
}

@end
