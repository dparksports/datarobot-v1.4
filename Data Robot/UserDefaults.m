//
//  UserDefaults.m
//  S5
//
//  Created by Dan Park on 6/6/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "UserDefaults.h"

// Remained Call Minutes
NSString *DayMinutesRemained = @"DayMinutesRemained";
NSString *NightMinutesRemained = @"NightMinutesRemained";
NSString *WeekendMinutesRemained = @"WeekendMinutesRemained";
NSString *NWMinutesRemained = @"NWMinutesRemained";
NSString *FamilyMinutesRemained = @"FamilyMinutesRemained";
NSString *MyFamilyShareMinutesRemained = @"MyFamilyShareMinutesRemained";
NSString *RolloverMinutesRemained = @"RolloverMinutesRemained";
NSString *LifeMinutesRemained = @"LifeMinutesRemained";


// Used Call Minutes
NSString *DayMinutesUsed = @"DayMinutesUsed";
NSString *NightMinutesUsed = @"NightMinutesUsed";
NSString *WeekendMinutesUsed = @"WeekendMinutesUsed";
NSString *NWMinutesUsed = @"NWMinutesUsed";
NSString *FamilyMinutesUsed = @"FamilyMinutesUsed";
NSString *MyFamilyShareMinutesUsed = @"MyFamilyShareMinutesUsed";
NSString *RolloverMinutesUsed = @"RolloverMinutesUsed";
NSString *LifeMinutesUsed = @"LifeMinutesUsed";




// My Call Minutes Quota
NSString *DayMinutes = @"DayMinutes";
NSString *NightMinutes = @"NightMinutes";
NSString *WeekendMinutes = @"WeekendMinutes";
NSString *NWMinutes = @"NWMinutes";
NSString *RolloverMinutes = @"RolloverMinutes";
NSString *FamilyMinutes = @"FamilyMinutes";
NSString *MyFamilyShareMinutes = @"MyFamilyShareMinutes";


NSString *WeekNightStartHour = @"WeekNightStartHour";
NSString *WeekNightEndHour = @"WeekNightEndHour";
NSString *WeekNightStartMinutes = @"WeekNightStartMinutes";
NSString *WeekNightEndMinutes = @"WeekNightEndMinutes";
NSString *WeekNightStartDay = @"WeekNightStartDay";
NSString *WeekNightEndDay = @"WeekNightEndDay";


NSString *WeekendStartHour = @"WeekendStartHour";
NSString *WeekendEndHour = @"WeekendEndHour";
NSString *WeekendStartMinutes = @"WeekendStartMinutes";
NSString *WeekendEndMinutes = @"WeekendEndMinutes";
NSString *WeekendStartDay = @"WeekendStartDay";
NSString *WeekendEndDay = @"WeekendEndDay";


NSString *SpilloverSecondsUsed = @"SpilloverSecondsUsed";
NSString *SpilloverStartTime = @"SpilloverStartTime";
NSString *SpilloverEndTime = @"SpilloverEndTime";
NSString *SpilloverCallPeriod = @"SpilloverCallPeriod";

NSString *LastCallSecondsUsed = @"LastCallSecondsUsed";
NSString *LastCallStartTime = @"LastCallStartTime";
NSString *LastCallEndTime = @"LastCallEndTime";
NSString *LastCallPeriod = @"LastCallPeriod";


NSString *MinutesResetDay = @"MinutesResetDay";
NSString *ShowRemainedUsage = @"ShowRemainedUsage";
NSString *TrackIndividualNW = @"TrackIndividualNW";

NSString *LowMinutesAlarm = @"LowMinutesAlarm"; // alarm me when 100 mins low.
NSString *ResetDayAlarm = @"ResetDayAlarm";     // alarm me 7 days before reset

NSString *UnlimitedMinutes = @"UnlimitedMinutes";
NSString *UnlimitedNightMinutes = @"UnlimitedNightMinutes";
NSString *UnlimitedWeekendMinutes = @"UnlimitedWeekendMinutes";
NSString *UnlimitedNightWeekendMinutes = @"UnlimitedNightWeekendMinutes";

NSString *MonitorLocation = @"MonitorLocation";


// auto switch to see the minutes left count.
NSString *MonitorLiveCallAlarm = @"MonitorLiveCallAlarm";         
NSString *MonitorLiveFilterSeconds = @"MonitorLiveFilterSeconds";


NSString *LastCallShowAlarm = @"LastCallShowAlarm";     //show me the last call minutes.
NSString *LastCallFilterSeconds = @"LastCallFilterSeconds"; 

NSString *LiveCallShowAlarm = @"LiveCallShowAlarm";     //show me a live call limit alert.
NSString *LiveCallFilterSeconds = @"LiveCallFilterSeconds"; 

NSString *CountIncomingCalls = @"CountIncomingCalls"; 


NSString *ShowLastCallUsage = @"ShowLastCallUsage";
NSString *ShowCallUsage = @"ShowCallUsage";
NSString *LaunchedPreviously = @"LaunchedPreviously";
NSString *PurchasedTrackPeakMinutes = @"PurchasedTrackPeakMinutes";
NSString *ResetBillingCycle = @"ResetBillingCycle";


// Used Minutes Row Animation

// Rollover Used Minutes Row Animation
NSString *AddRolloverRowAnimated = @"AddRolloverRowAnimated";
NSString *RemoveRolloverRowAnimated = @"RemoveRolloverRowAnimated";
NSString *EnableRolloverChanged = @"EnableRolloverChanged";
NSString *EnableRollover = @"EnableRollover";

// Lifetime Used Minutes Row Animation
NSString *AddLifetimeRowAnimated = @"AddLifetimeRowAnimated";
NSString *RemoveLifetimeRowAnimated = @"RemoveLifetimeRowAnimated";
NSString *ShowLifetimeChanged = @"ShowLifetimeChanged";
NSString *ShowLifetime = @"ShowLifetime";

// Night & Weekend Used Minutes Row Animation
NSString *AddNightWeekendRowAnimated = @"AddNightWeekendRowAnimated";
NSString *RemoveNightWeekendRowAnimated = @"RemoveNightWeekendRowAnimated";
NSString *ShowNightWeekendChanged = @"ShowNightWeekendChanged";
NSString *ShowNightWeekend = @"ShowNightWeekend";

// Weekend Used Minutes Row Animation
NSString *AddWeekendRowAnimated = @"AddWeekendRowAnimated";
NSString *RemoveWeekendRowAnimated = @"RemoveWeekendRowAnimated";
NSString *ShowWeekendChanged = @"ShowWeekendChanged";
NSString *ShowWeekend = @"ShowWeekend";

// Night Used Minutes Row Animation
NSString *AddNightRowAnimated = @"AddNightRowAnimated";
NSString *RemoveNightRowAnimated = @"RemoveNightRowAnimated";
NSString *ShowNightChanged = @"ShowNightChanged";
NSString *ShowNight = @"ShowNight";

// Day Used Minutes Row Animation
NSString *AddDayRowAnimated = @"AddDayRowAnimated";
NSString *RemoveDayRowAnimated = @"RemoveDayRowAnimated";
NSString *ShowDayChanged = @"ShowDayChanged";
NSString *ShowDay = @"ShowDay";


// Last Call Used Row Animation
NSString *AddLastCallUsedRowAnimated = @"AddLastCallUsedRowAnimated";
NSString *RemoveLastCallUsedRowAnimated = @"RemoveLastCallUsedRowAnimated";
NSString *ShowLastCallUsedChanged = @"ShowLastCallUsedChanged";
NSString *ShowLastCallUsed = @"ShowLastCallUsed";

// Last Call Start End Row Animation
NSString *AddLastCallStartEndRowAnimated = @"AddLastCallStartEndRowAnimated";
NSString *RemoveLastCallStartEndRowAnimated = @"RemoveLastCallStartEndRowAnimated";
NSString *ShowLastCallStartEndChanged = @"ShowLastCallStartEndChanged";
NSString *ShowLastCallStartEnd = @"ShowLastCallStartEnd";

// Last Call Period Row Animation
NSString *AddLastCallPeriodRowAnimated = @"AddLastCallPeriodRowAnimated";
NSString *RemoveLastCallPeriodRowAnimated = @"RemoveLastCallPeriodRowAnimated";
NSString *ShowLastCallPeriodChanged = @"ShowLastCallPeriodChanged";
NSString *ShowLastCallPeriod = @"ShowLastCallPeriod";


// Spillover Call Used Row Animation
NSString *AddSpilloverCallUsedRowAnimated = @"AddSpilloverCallUsedRowAnimated";
NSString *RemoveSpilloverCallUsedRowAnimated = @"RemoveSpilloverCallUsedRowAnimated";
NSString *ShowSpilloverCallUsedChanged = @"ShowSpilloverCallUsedChanged";
NSString *ShowSpilloverCallUsed = @"ShowSpilloverCallUsed";

// Spillover Call Start End Row Animation
NSString *AddSpilloverCallStartEndRowAnimated = @"AddSpilloverCallStartEndRowAnimated";
NSString *RemoveSpilloverCallStartEndRowAnimated = @"RemoveSpilloverCallStartEndRowAnimated";
NSString *ShowSpilloverCallStartEndChanged = @"ShowSpilloverCallStartEndChanged";
NSString *ShowSpilloverCallStartEnd = @"ShowSpilloverCallStartEnd";

// Spillover Call Period Row Animation
NSString *AddSpilloverCallPeriodRowAnimated = @"AddSpilloverCallPeriodRowAnimated";
NSString *RemoveSpilloverCallPeriodRowAnimated = @"RemoveSpilloverCallPeriodRowAnimated";
NSString *ShowSpilloverCallPeriodChanged = @"ShowSpilloverCallPeriodChanged";
NSString *ShowSpilloverCallPeriod = @"ShowSpilloverCallPeriod";


@implementation UserDefaults

- (void)resetUsage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL trackIndividualNW = [defaults boolForKey:TrackIndividualNW];
    
    [defaults setInteger:0 forKey:DayMinutesUsed];
    [defaults setInteger:0 forKey:NightMinutesUsed];
    [defaults setInteger:0 forKey:WeekendMinutesUsed];
    [defaults setInteger:0 forKey:NWMinutesUsed];
    [defaults setInteger:0 forKey:RolloverMinutesUsed];
    
    [defaults setInteger:[defaults integerForKey:DayMinutes] forKey:DayMinutesRemained];
    [defaults setInteger:[defaults integerForKey:(trackIndividualNW) ? NightMinutes : NWMinutes] forKey:NightMinutesRemained];
    [defaults setInteger:[defaults integerForKey:(trackIndividualNW) ? WeekendMinutes : NWMinutes] forKey:WeekendMinutesRemained];
    [defaults setInteger:[defaults integerForKey:NWMinutes] forKey:NWMinutesRemained];
    [defaults setInteger:[defaults integerForKey:RolloverMinutes] forKey:RolloverMinutesRemained];
}

- (void)populate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // 5th day of every month
	[defaults setInteger:5 forKey:MinutesResetDay];
    
    // alert me 7 days before reset. 0 for alarm disabled.
	[defaults setInteger:7 forKey:ResetDayAlarm];
    
    // alert me 100 mins low. 0 for alarm disabled.
    [defaults setInteger:100 forKey:LowMinutesAlarm];

    
    // Week Night Start Time 9pm (24 hours)
    [defaults setInteger:12+9 forKey:WeekNightStartHour];
    [defaults setInteger:1 forKey:WeekNightStartMinutes];
    // Week Night Start Weekday :
    // 1 = Sun, 2 = Mon, 3 = Tues, 4 = Wed, 5 = Thurs, 6 = Fri, Sat = 7
    [defaults setInteger:2 forKey:WeekNightStartDay];
    
    
    // Week Night End Time 5:59am (24 hours)
    [defaults setInteger:5 forKey:WeekNightEndHour];
    [defaults setInteger:59 forKey:WeekNightEndMinutes];
    // Week Night End Weekday 
    // 1 = Sun, 2 = Mon, 3 = Tues, 4 = Wed, 5 = Thurs, 6 = Fri, Sat = 7
    [defaults setInteger:6 forKey:WeekNightEndDay];
    
    
    // Weekend Start Time: 9 pm (24 hours)
    [defaults setInteger:0 forKey:WeekendStartHour];
    [defaults setInteger:0 forKey:WeekendStartMinutes];
    // Weekend Start Day 
    // 1 = Sun, 2 = Mon, 3 = Tues, 4 = Wed, 5 = Thurs, 6 = Fri, Sat = 7
    [defaults setInteger:7 forKey:WeekendStartDay];
    
    // Weekend End Time: 5:59 am (24 hours)
    [defaults setInteger:12+11 forKey:WeekendEndHour];
    [defaults setInteger:59 forKey:WeekendEndMinutes];
    // Weekend End Day 
    // 1 = Sun, 2 = Mon, 3 = Tues, 4 = Wed, 5 = Thurs, 6 = Fri, Sat = 7
    [defaults setInteger:1 forKey:WeekendEndDay];


    // Remained Call Minutes
//    [defaults setInteger:450 forKey:DayMinutesRemained];
//    [defaults setInteger:5000 forKey:NightMinutesRemained];
//    [defaults setInteger:5000 forKey:WeekendMinutesRemained];
//    [defaults setInteger:5000 forKey:NWMinutesRemained];
//    [defaults setInteger:1000 forKey:RolloverMinutesRemained];
    [defaults setInteger:9999 forKey:LifeMinutesRemained];
    [defaults setInteger:500 forKey:FamilyMinutesRemained];
    [defaults setInteger:250 forKey:MyFamilyShareMinutesRemained];

    
    // Used Call Minutes
//    [defaults setInteger:0 forKey:DayMinutesUsed];
//    [defaults setInteger:0 forKey:NightMinutesUsed];
//    [defaults setInteger:0 forKey:WeekendMinutesUsed];
//    [defaults setInteger:0 forKey:NWMinutesUsed];
//    [defaults setInteger:0 forKey:RolloverMinutesUsed];
    [defaults setInteger:0 forKey:LifeMinutesUsed];
    [defaults setInteger:112 forKey:FamilyMinutesUsed];
    [defaults setInteger:223 forKey:MyFamilyShareMinutesUsed];

    
	[defaults setInteger:450 forKey:DayMinutes];
	[defaults setInteger:3000 forKey:NightMinutes];
	[defaults setInteger:2000 forKey:WeekendMinutes];
	[defaults setInteger:5000 forKey:NWMinutes];
	[defaults setInteger:1000 forKey:RolloverMinutes];
	[defaults setInteger:500 forKey:FamilyMinutes];
	[defaults setInteger:250 forKey:MyFamilyShareMinutes];

    
    
    // 6/27 : Last Call Period is zero (unknown).
	[defaults setInteger:0 forKey:LastCallPeriod];
	[defaults setInteger:0 forKey:LastCallSecondsUsed];

    // 7/6 : Spillover Usage
    [defaults setInteger:0 forKey:SpilloverCallPeriod];
	[defaults setInteger:0 forKey:SpilloverSecondsUsed];


	[defaults setBool:YES forKey:MonitorLocation];
	[defaults setBool:YES forKey:ShowRemainedUsage];
	[defaults setBool:NO forKey:TrackIndividualNW];

    
	[defaults setBool:NO forKey:LastCallShowAlarm];
    // 6/23 : Last Call Alert Filter at 60 seconds.
	[defaults setInteger:60 forKey:LastCallFilterSeconds];

    
    // 10/4 : Live Call Limit Alert
    [defaults setBool:YES forKey:LiveCallShowAlarm];
    // 11/8 : Supports 5 Min free call carriers.
	[defaults setInteger:4*60 forKey:LiveCallFilterSeconds];

    // 11/8 : Show Flip Timer after MonitorLiveFilterSeconds. 
    [defaults setBool:NO forKey:MonitorLiveCallAlarm];
	[defaults setInteger:60*3 forKey:MonitorLiveFilterSeconds];

    
    [defaults setBool:YES forKey:CountIncomingCalls];
    
    
    [defaults setBool:NO forKey:UnlimitedMinutes];
    [defaults setBool:NO forKey:UnlimitedNightMinutes];
    [defaults setBool:NO forKey:UnlimitedWeekendMinutes];
    [defaults setBool:NO forKey:UnlimitedNightWeekendMinutes];
    
	[defaults setBool:YES forKey:ShowLastCallUsage];
	[defaults setBool:YES forKey:ShowCallUsage];
	[defaults setBool:YES forKey:LaunchedPreviously];
	[defaults setBool:YES forKey:PurchasedTrackPeakMinutes];
	[defaults setBool:NO forKey:ResetBillingCycle];
    
    
    // Rollover row
	[defaults setBool:YES forKey:AddRolloverRowAnimated];
	[defaults setBool:YES forKey:RemoveRolloverRowAnimated];
    [defaults setBool:NO forKey:EnableRolloverChanged];
    [defaults setBool:NO forKey:EnableRollover];

    // Lifetime row
	[defaults setBool:YES forKey:AddLifetimeRowAnimated];
	[defaults setBool:YES forKey:RemoveLifetimeRowAnimated];
    [defaults setBool:NO forKey:ShowLifetimeChanged];
    [defaults setBool:YES forKey:ShowLifetime];
    
    // Night and Weekend row
	[defaults setBool:YES forKey:AddNightWeekendRowAnimated];
	[defaults setBool:YES forKey:RemoveNightWeekendRowAnimated];
    [defaults setBool:NO forKey:ShowNightWeekendChanged];
    [defaults setBool:YES forKey:ShowNightWeekend];
    
    // Weekend row
	[defaults setBool:YES forKey:AddWeekendRowAnimated];
	[defaults setBool:YES forKey:RemoveWeekendRowAnimated];
    [defaults setBool:NO forKey:ShowWeekendChanged];
    [defaults setBool:NO forKey:ShowWeekend];
    
    // Night row
	[defaults setBool:YES forKey:AddNightRowAnimated];
	[defaults setBool:YES forKey:RemoveNightRowAnimated];
    [defaults setBool:NO forKey:ShowNightChanged];
    [defaults setBool:NO forKey:ShowNight];
    
    // Day row
	[defaults setBool:YES forKey:AddDayRowAnimated];
	[defaults setBool:YES forKey:RemoveDayRowAnimated];
    [defaults setBool:NO forKey:ShowDayChanged];
    [defaults setBool:YES forKey:ShowDay];
    
    
    // ** SpillOver VC Use Only ***
     
    // Last Call Used Row Animation
	[defaults setBool:YES forKey:AddLastCallUsedRowAnimated];
	[defaults setBool:YES forKey:RemoveLastCallUsedRowAnimated];
    [defaults setBool:NO forKey:ShowLastCallUsedChanged];
    [defaults setBool:YES forKey:ShowLastCallUsed];
    
    // Last Call Start End Row Animation
	[defaults setBool:YES forKey:AddLastCallStartEndRowAnimated];
	[defaults setBool:YES forKey:RemoveLastCallStartEndRowAnimated];
    [defaults setBool:NO forKey:ShowLastCallStartEndChanged];
    [defaults setBool:YES forKey:ShowLastCallStartEnd];
    
    // Last Call Period Row Animation
	[defaults setBool:YES forKey:AddLastCallPeriodRowAnimated];
	[defaults setBool:YES forKey:RemoveLastCallPeriodRowAnimated];
    [defaults setBool:NO forKey:ShowLastCallPeriodChanged];
    [defaults setBool:YES forKey:ShowLastCallPeriod];
    
    
    // Spillover Call Used Row Animation
	[defaults setBool:YES forKey:AddSpilloverCallUsedRowAnimated];
	[defaults setBool:YES forKey:RemoveSpilloverCallUsedRowAnimated];
    [defaults setBool:NO forKey:ShowSpilloverCallUsedChanged];
    // 7/15 : spillover call used row shouldn't show until spillover seconds is above zero.
    [defaults setBool:YES forKey:ShowSpilloverCallUsed];
    
    // Spillover Call Start End Row Animation
	[defaults setBool:YES forKey:AddSpilloverCallStartEndRowAnimated];
	[defaults setBool:YES forKey:RemoveSpilloverCallStartEndRowAnimated];
    [defaults setBool:NO forKey:ShowSpilloverCallStartEndChanged];
    [defaults setBool:YES forKey:ShowSpilloverCallStartEnd];
    
    // Spillover Call Period Row Animation
	[defaults setBool:YES forKey:AddSpilloverCallPeriodRowAnimated];
	[defaults setBool:YES forKey:RemoveSpilloverCallPeriodRowAnimated];
    [defaults setBool:NO forKey:ShowSpilloverCallPeriodChanged];
    [defaults setBool:YES forKey:ShowSpilloverCallPeriod];
    
    // ** SpillOver VC Use Only ***
}

- (void)configureDefaults
{
    [self defaultsDidChange:nil]; // load preferences from disk
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification object:nil];
    
	if (![[NSUserDefaults standardUserDefaults] boolForKey:LaunchedPreviously]) {
        [self populate];
        [self resetUsage];
	}
}

- (void)dealloc  {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) 
    {
    }
    return self;
}

static UserDefaults *singleton = nil;
+ (UserDefaults *)sharedInstance 
{
	if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          singleton = [[[self class] alloc] init];
                          [singleton configureDefaults];
                      });
	}
    
    //	if (!singleton) {
    //		singleton = [[[self class] alloc] init];
    //	}
	return singleton;
}

+ (NSString*)yesOrNo:(BOOL)flag
{
    return flag ? @"YES" : @"NO";
}

+ (void)inspectUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@:%@", MonitorLocation, [self.class yesOrNo:[defaults boolForKey:MonitorLocation]]
          );
    NSLog(@"%@:%@", MonitorLiveCallAlarm, [self.class yesOrNo:[defaults boolForKey:MonitorLiveCallAlarm]]
          );
    NSLog(@"%@:%@", LastCallShowAlarm, [self.class yesOrNo:[defaults boolForKey:LastCallShowAlarm]]);
    
    NSLog(@"%@:%ld", MinutesResetDay, (long)[defaults integerForKey:MinutesResetDay]);
    NSLog(@"%@:%ld", ResetDayAlarm, [defaults integerForKey:ResetDayAlarm]);
    NSLog(@"%@:%ld", LowMinutesAlarm, [defaults integerForKey:LowMinutesAlarm]);
    NSLog(@"%@:%ld", WeekNightStartHour, [defaults integerForKey:WeekNightStartHour]);
    NSLog(@"%@:%ld", WeekNightStartMinutes, [defaults integerForKey:WeekNightStartMinutes]);
    NSLog(@"%@:%ld", WeekNightStartDay, [defaults integerForKey:WeekNightStartDay]);
    
    
    NSLog(@"%@:%ld", DayMinutesRemained, [defaults integerForKey:DayMinutesRemained]);
    NSLog(@"%@:%ld", NightMinutes, [defaults integerForKey:NightMinutes]);
    NSLog(@"%@:%ld", WeekendMinutes, [defaults integerForKey:WeekendMinutes]);
    NSLog(@"%@:%ld", LastCallSecondsUsed, [defaults integerForKey:LastCallSecondsUsed]);
    NSLog(@"%@:%ld", RolloverMinutes, [defaults integerForKey:RolloverMinutes]);
    NSLog(@"%@:%ld", LifeMinutesUsed, [defaults integerForKey:LifeMinutesUsed]);
}

- (void)defaultsDidChange:(NSNotification*)notification {
	BOOL synchronized = [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
