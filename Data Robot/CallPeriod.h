//
//  CallPeriod.h
//  S8
//
//  Created by Dan Park on 7/18/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallPeriod : NSObject


// Night Period
+ (NSDate*)nightStartTimeDateWithSeedTime:(NSTimeInterval)callTime;
+ (NSDate*)nightEndTimeDateWithSeedTime:(NSTimeInterval)callTime;

+ (BOOL)isCallWithinNightTimeWindow:(NSTimeInterval)callTime;
+ (BOOL)isCallTimeAfterNightStartWeekday:(NSTimeInterval)callTime;
+ (BOOL)isCallTimeBeforeNightEndWeekday:(NSTimeInterval)callTime;


// Weekend Period
+ (NSDate*)startWeekendDateWithSeedTime:(NSTimeInterval)callTime;
+ (NSDate*)endWeekendDateWithSeedTime:(NSTimeInterval)callTime;

+ (BOOL)isCallTimeAfterWeekendStartTime:(NSTimeInterval)callTime;
+ (BOOL)isCallTimeBeforeWeekendEndTime:(NSTimeInterval)callTime;

+ (BOOL)isCallWithinWeekendTimeWindow:(NSTimeInterval)callTime;

@end
