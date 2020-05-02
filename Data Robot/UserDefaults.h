//
//  UserDefaults.h
//  S5
//
//  Created by Dan Park on 6/6/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *WeekNightStartHour;
extern NSString *WeekNightEndHour;
extern NSString *WeekNightStartMinutes;
extern NSString *WeekNightEndMinutes;
extern NSString *WeekNightStartDay;
extern NSString *WeekNightEndDay;

extern NSString *WeekendStartHour;
extern NSString *WeekendEndHour;
extern NSString *WeekendStartMinutes;
extern NSString *WeekendEndMinutes;
extern NSString *WeekendStartDay;
extern NSString *WeekendEndDay;

// Spillover Usage
extern NSString *SpilloverCallPeriod;
extern NSString *SpilloverSecondsUsed;
extern NSString *SpilloverStartTime;
extern NSString *SpilloverEndTime;

// Last Call
extern NSString *LastCallPeriod;
extern NSString *LastCallSecondsUsed;
extern NSString *LastCallStartTime;
extern NSString *LastCallEndTime;

extern NSString *LastCallShowAlarm;
extern NSString *LastCallFilterSeconds;

// Live Call Limit Alert
extern NSString *LiveCallShowAlarm;
extern NSString *LiveCallFilterSeconds;

// Count Incoming Call Minutes
extern NSString *CountIncomingCalls;


// Remained Minutes
extern NSString *DayMinutesRemained;
extern NSString *NightMinutesRemained;
extern NSString *WeekendMinutesRemained;
extern NSString *NWMinutesRemained;
extern NSString *RolloverMinutesRemained;
extern NSString *LifeMinutesRemained;
extern NSString *FamilyMinutesRemained;
extern NSString *MyFamilyShareMinutesRemained;


// Used Minutes
extern NSString *DayMinutesUsed;
extern NSString *NightMinutesUsed;
extern NSString *WeekendMinutesUsed;
extern NSString *NWMinutesUsed;
extern NSString *RolloverMinutesUsed;
extern NSString *LifeMinutesUsed;
extern NSString *FamilyMinutesUsed;
extern NSString *MyFamilyShareMinutesUsed;

extern NSString *UnlimitedMinutes;
extern NSString *UnlimitedNightMinutes;
extern NSString *UnlimitedWeekendMinutes;
extern NSString *UnlimitedNightWeekendMinutes;


// Monthly Minutes Quota
extern NSString *DayMinutes;
extern NSString *NightMinutes;
extern NSString *WeekendMinutes;
extern NSString *NWMinutes;
extern NSString *RolloverMinutes;
extern NSString *FamilyMinutes;
extern NSString *MyFamilyShareMinutes;

extern NSString *MinutesResetDay;

extern NSString *LowMinutesAlarm; 
extern NSString *ResetDayAlarm;     


extern NSString *MonitorLiveCallAlarm; 
extern NSString *MonitorLiveFilterSeconds; 


extern NSString *MonitorLocation;     
extern NSString *ShowRemainedUsage;     
extern NSString *TrackIndividualNW;     


extern NSString *ShowLastCallUsage;
extern NSString *ShowCallUsage;
extern NSString *LaunchedPreviously;
extern NSString *ResetBillingCycle;
extern NSString *PurchasedTrackPeakMinutes;


// Rollover Row Animation
extern NSString *AddRolloverRowAnimated;
extern NSString *RemoveRolloverRowAnimated;
extern NSString *EnableRollover;
extern NSString *EnableRolloverChanged;

// Lifetime Row Animation
extern NSString *AddLifetimeRowAnimated;
extern NSString *RemoveLifetimeRowAnimated;
extern NSString *ShowLifetimeChanged;
extern NSString *ShowLifetime;

// Night & Weekend Row Animation
extern NSString *AddNightWeekendRowAnimated;
extern NSString *RemoveNightWeekendRowAnimated;
extern NSString *ShowNightWeekendChanged;
extern NSString *ShowNightWeekend;

// Weekend Row Animation
extern NSString *AddWeekendRowAnimated;
extern NSString *RemoveWeekendRowAnimated;
extern NSString *ShowWeekendChanged;
extern NSString *ShowWeekend;

// Night Row Animation
extern NSString *AddNightRowAnimated;
extern NSString *RemoveNightRowAnimated;
extern NSString *ShowNightChanged;
extern NSString *ShowNight;

// Day Row Animation
extern NSString *AddDayRowAnimated;
extern NSString *RemoveDayRowAnimated;
extern NSString *ShowDayChanged;
extern NSString *ShowDay;


// Last Call Used Row Animation
extern NSString *AddLastCallUsedRowAnimated;
extern NSString *RemoveLastCallUsedRowAnimated;
extern NSString *ShowLastCallUsedChanged;
extern NSString *ShowLastCallUsed;

// Last Call Start End Row Animation
extern NSString *AddLastCallStartEndRowAnimated;
extern NSString *RemoveLastCallStartEndRowAnimated;
extern NSString *ShowLastCallStartEndChanged;
extern NSString *ShowLastCallStartEnd;

// Last Call Period Row Animation
extern NSString *AddLastCallPeriodRowAnimated;
extern NSString *RemoveLastCallPeriodRowAnimated;
extern NSString *ShowLastCallPeriodChanged;
extern NSString *ShowLastCallPeriod;


// Spillover Call Used Row Animation
extern NSString *AddSpilloverCallUsedRowAnimated;
extern NSString *RemoveSpilloverCallUsedRowAnimated;
extern NSString *ShowSpilloverCallUsedChanged;
extern NSString *ShowSpilloverCallUsed;

// Spillover Call Start End Row Animation
extern NSString *AddSpilloverCallStartEndRowAnimated;
extern NSString *RemoveSpilloverCallStartEndRowAnimated;
extern NSString *ShowSpilloverCallStartEndChanged;
extern NSString *ShowSpilloverCallStartEnd;

// Spillover Call Period Row Animation
extern NSString *AddSpilloverCallPeriodRowAnimated;
extern NSString *RemoveSpilloverCallPeriodRowAnimated;
extern NSString *ShowSpilloverCallPeriodChanged;
extern NSString *ShowSpilloverCallPeriod;

@interface UserDefaults : NSObject

+ (NSString*)yesOrNo:(BOOL)flag;
+ (void)inspectUserDefaults;
+ (UserDefaults *)sharedInstance;

- (void)defaultsDidChange:(NSNotification*)notification;

@end
