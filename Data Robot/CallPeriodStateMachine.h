//
//  CallPeriod.h
//  S6
//
//  Created by Dan Park on 7/6/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    CallPeriodDay,
    CallPeriodNight = 1 << 0,
    CallPierodWeekend = 1 << 1,    
};

#define CallPeriodDay 1
#define CallPeriodNight 2
#define CallPeriodWeekend 3
#define CallPeriodRollover 4

@interface CallPeriodStateMachine : NSObject
{
    NSInteger lastCallSeconds;
    NSInteger spillOverSeconds;
//    BOOL savedUsedMinutes;
}
@property (nonatomic, assign) NSInteger lastCallSeconds;

+ (CallPeriodStateMachine *)sharedInstance;
+ (NSString*)callPeriod:(NSInteger)period;

- (BOOL)updateWeekendMinutes:(NSInteger)usedSeconds start:(NSTimeInterval)lastCallStartTime end:(NSTimeInterval)lastCallEndTime;
- (BOOL)updateNightMinutes:(NSInteger)usedSeconds start:(NSTimeInterval)callStartTime end:(NSTimeInterval)callEndTime;
- (void)updateDayMinutes:(NSInteger)usedSeconds start:(NSTimeInterval)callStartTime end:(NSTimeInterval)callEndTime;

- (void)updateDefaults:(NSInteger)usedSeconds lastCallStartTime:(NSTimeInterval)lastCallStartTime lastCallEndTime:(NSTimeInterval)lastCallEndTime;

@end
