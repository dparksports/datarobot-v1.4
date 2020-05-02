//
//  StatsManager.m
//  S3
//
//  Created by Dan Park on 5/19/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "StatsManager.h"
#import "CallManager.h"
#import "CallEvent.h"
#import "HistoryManager.h"
#import "LocationManager.h"

#import "UserDefaults.h"
#import "Formats.h"
#import "CalendarComponents.h"
#import "CallPeriodStateMachine.h"
#import "DebugManager.h"

NSString *kLogTableRefreshEvent = @"kLogTableRefreshEvent";	 
NSString *kUpdatedUsageEvent = @"kUpdatedUsageEvent";	 
NSString *kCallDuration = @"kCallDuration";	 

@implementation StatsManager

@synthesize serialQueue;

@synthesize disconnectedCallID;
//@synthesize disconnectedTime;

@synthesize connectedCallSet, callDictionary;

@synthesize events;


- (NSString*)callUsagePerPeriod:(NSInteger)callPeriod
{
    NSString *usedMinutesString;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL unlimitedMinutes = [defaults boolForKey:UnlimitedMinutes];
    BOOL unlimitedNightMinutes = [defaults boolForKey:UnlimitedNightMinutes];
    BOOL unlimitedWeekendMinutes = [defaults boolForKey:UnlimitedWeekendMinutes];
    BOOL trackIndividualNW = [defaults boolForKey:TrackIndividualNW];

    switch (callPeriod) {
        case CallPeriodDay:
            usedMinutesString = [Formats formatMinuteUsage:[defaults integerForKey:DayMinutesUsed] monthly:(unlimitedMinutes) ? 0 : [defaults integerForKey:DayMinutes] isUnlimited:unlimitedMinutes];
            break;
        case CallPeriodNight:
            usedMinutesString = [Formats formatNightMinuteUsage:[defaults integerForKey:NightMinutesUsed] monthly:(unlimitedNightMinutes) ? 0 : [defaults integerForKey:(trackIndividualNW) ? NightMinutes : NWMinutes] isUnlimited:unlimitedNightMinutes];
            break;
        case CallPeriodWeekend:
            usedMinutesString = [Formats formatWeekendMinuteUsage:[defaults integerForKey:WeekendMinutesUsed] monthly:(unlimitedWeekendMinutes) ? 0 : [defaults integerForKey:(trackIndividualNW) ? WeekendMinutes : NWMinutes] isUnlimited:unlimitedWeekendMinutes];
            break;
        case CallPeriodRollover:
            usedMinutesString = [Formats formatMinuteUsage:[defaults integerForKey:RolloverMinutesUsed] monthly:(unlimitedMinutes) ? 0 : [defaults integerForKey:RolloverMinutes] isUnlimited:unlimitedMinutes];
            break;
        default:
            usedMinutesString = [NSString string];
            break;
    }
    return usedMinutesString;
}

+ (void)scheduleAlarmForDate:(NSDate*)now withMessage:(NSString*)message
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    if (localNotification)
    {
        localNotification.hasAction = YES;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertAction = @"Check";
        localNotification.alertBody = message;
        [app presentLocalNotificationNow:localNotification];
    }
}

- (void)saveLastCallHistory:(NSString*)callPeriod
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval callStart = [defaults doubleForKey:LastCallStartTime];
    NSTimeInterval callEnd = [defaults doubleForKey:LastCallEndTime];
    NSInteger usedSeconds = [defaults integerForKey:LastCallSecondsUsed];
    
    HistoryManager *manager = [HistoryManager sharedInstance];
    [manager addCallEvent:callPeriod callStart:callStart callEnd:callEnd duration:usedSeconds];
    [manager saveProperyList];

    
    [DebugManager printMinutesUsedStartEndTimes:[NSString stringWithFormat:@"%s",__FUNCTION__] start:callStart end:callEnd usage:usedSeconds];
}

- (void)saveSpilloverCallHistory:(NSString*)callPeriod
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval callStart = [defaults doubleForKey:SpilloverStartTime];
    NSTimeInterval callEnd = [defaults doubleForKey:SpilloverEndTime];
    NSInteger usedSeconds = [defaults integerForKey:SpilloverSecondsUsed];
    
    HistoryManager *manager = [HistoryManager sharedInstance];
    [manager addCallEvent:callPeriod callStart:callStart callEnd:callEnd duration:usedSeconds];
    [manager saveProperyList];
    

    [DebugManager printMinutesUsedStartEndTimes:[NSString stringWithFormat:@"%s",__FUNCTION__] start:callStart end:callEnd usage:usedSeconds];
}

- (void)localNotifyNow
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger spilloverCallSeconds = [defaults integerForKey:SpilloverSecondsUsed];
    lastCallSeconds = [defaults integerForKey:LastCallSecondsUsed];
    
    
    
    NSInteger lastCallPeriod = [defaults integerForKey:LastCallPeriod];
    NSInteger spilloverCallPeriod = [defaults integerForKey:SpilloverCallPeriod];

    NSString *lastCallPeriodString = [CallPeriodStateMachine callPeriod:lastCallPeriod];
    NSString *spilloverPeriodString = [CallPeriodStateMachine callPeriod:spilloverCallPeriod];

    NSInteger totalSeconds;
    NSString *callUsages;
    if (spilloverCallSeconds > 0) 
    {
        
        totalSeconds = lastCallSeconds + spilloverCallSeconds;
        callUsages = [NSString stringWithFormat:@"%@ %@\n%@ %@",
                       [self callUsagePerPeriod:lastCallPeriod],lastCallPeriodString,
                      
                       [self callUsagePerPeriod:spilloverCallPeriod],spilloverPeriodString
                      ];
        
        [self saveLastCallHistory:lastCallPeriodString];
        [self saveSpilloverCallHistory:spilloverPeriodString];
    } 
    else 
    {
        totalSeconds = lastCallSeconds;
        callUsages = [NSString stringWithFormat:@"%@ %@",
                      [self callUsagePerPeriod:lastCallPeriod],
                      [CallPeriodStateMachine callPeriod:lastCallPeriod]];
        
        [self saveLastCallHistory:lastCallPeriodString];
    }
    

    
    NSString *message = [NSString stringWithFormat:@"Used %@\n%@",
                         [Formats shortFormatMinuteUsage:[Formats minutesUsed:totalSeconds]],
                         callUsages];
    switch ([UIApplication sharedApplication].applicationState) {
        default:
            break;
        case UIApplicationStateInactive:
            break;
        case UIApplicationStateBackground:
            break;
        case UIApplicationStateActive:
            break;
    }
    
    
    BOOL showLastCallAlarm = [defaults boolForKey:LastCallShowAlarm];
    NSInteger lastCallFilterSeconds = [defaults integerForKey:LastCallFilterSeconds];
    
    if (showLastCallAlarm && lastCallSeconds >= lastCallFilterSeconds) 
    {
        switch ([UIApplication sharedApplication].applicationState) {
            default:
            case UIApplicationStateInactive:
            case UIApplicationStateBackground:
                [self.class scheduleAlarmForDate:[NSDate date] withMessage:message];
                break;
            case UIApplicationStateActive:
                break;
        }
    }
}

- (void)calculateCallUsage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL countIncomingCalls = [defaults boolForKey:CountIncomingCalls];
    
    
    CallEvent *event = [callDictionary valueForKey:disconnectedCallID];
    if (event) 
    {
        if (! countIncomingCalls) 
        {
            if ([event isIncomingCall])
            {
                // 10/14 : remove the call event entry & call Id.
                [callDictionary removeObjectForKey:disconnectedCallID];
                [connectedCallSet removeObject:disconnectedCallID];
                return ;
            }
        }
        
        // 10/17 : calculate usage only when it has had been connected
        if (event.connectedTime <= 0)
        {
            // 10/24 : remove incoming or dialing call ID.
            [callDictionary removeObjectForKey:disconnectedCallID];
            [connectedCallSet removeObject:disconnectedCallID];
            return;
        }

        
        lastCallSeconds = event.disconnectedTime - [event eventTime];
        CallPeriodStateMachine *stateMachine = [CallPeriodStateMachine sharedInstance];
        stateMachine.lastCallSeconds = lastCallSeconds;
        
        [stateMachine updateDefaults:lastCallSeconds lastCallStartTime:[event eventTime] lastCallEndTime:event.disconnectedTime];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:lastCallSeconds], kCallDuration,
                                  [NSNumber numberWithDouble:event.disconnectedTime], kDisconnectedTime,
                                  [NSNumber numberWithDouble:[event eventTime]], kConnectedTime,
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedUsageEvent 
                                                            object:self 
                                                          userInfo:userInfo];
        
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^
                       {
                           [self localNotifyNow];
                       });

        // 10/14 : remove the call event entry & call Id.
        [callDictionary removeObjectForKey:disconnectedCallID];
        [connectedCallSet removeObject:disconnectedCallID];
    }
}

- (void)registerCallDialing
{
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallDialingEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kDialingTime];
         NSString *callID  = [userInfo objectForKey:kCallID];
         
         [connectedCallSet addObject:callID];
         
         CallEvent *event = [CallEvent instanceDialing:callID time:[number doubleValue]];
         [callDictionary setValue:event forKey:callID];
     }
     ];
}

- (void)registerCallIncoming
{
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallIncomingEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kIncomingTime];
         NSString *callID  = [userInfo objectForKey:kCallID];
         
         [connectedCallSet addObject:callID];
         
         CallEvent *event = [CallEvent instanceIncoming:callID time:[number doubleValue]];
         [callDictionary setValue:event forKey:callID];
     }
     ];
}

+ (void)notifyNow:(NSString*)message userInfo:(NSDictionary*)userInfo
{
    UILocalNotification *notify = [[UILocalNotification alloc] init];
    notify.alertAction = @"Open";
    notify.soundName = UILocalNotificationDefaultSoundName;
    notify.userInfo = userInfo;
    notify.alertBody = message;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notify];

    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^
                   {
                       
//                       LocationManager *manager = [LocationManager sharedInstance];
//                       [manager notifyLocally:message];
                       
                       
//                       [self.class scheduleAlarmForDate:nil withMessage:message];
                       
                       
//                       NSDate *fireDate = [CalendarComponents givenSecondsFromNow:1];
//                       [LocationManager scheduleNotify:fireDate userInfo:userInfo alert:message];
                   });
    
    
}

- (void)scheduleCallLimitAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger liveCallFilterSeconds = [defaults integerForKey:LiveCallFilterSeconds];
    if (! [self isCallConnected]) {
        return;
    }
    
    BOOL liveCallShowAlarm = [defaults boolForKey:LiveCallShowAlarm];
    if (liveCallShowAlarm) 
    {

        NSString *filterSeconds = [Formats trueHoursMinsSeconds:liveCallFilterSeconds];
        NSString *messageString = NSLocalizedString(@" - Time Limit Reached", nil);
        NSString *message = [NSString stringWithFormat:@"%@ %@", filterSeconds, messageString]; 
        
        NSString *alertBody = [NSString stringWithFormat:@"%@", message];
        NSDictionary *userInfoNotify = [NSDictionary dictionaryWithObject:
                                        [NSKeyedArchiver archivedDataWithRootObject:message] forKey:LiveCallShowAlarm];
        
        [self.class notifyNow:alertBody userInfo:userInfoNotify];
    }
}

- (void)internalScheduleCallLimitAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL liveCallShowAlarm = [defaults boolForKey:LiveCallShowAlarm];
    NSInteger liveCallFilterSeconds = [defaults integerForKey:LiveCallFilterSeconds];
    if (liveCallShowAlarm)
    {
        int64_t deltaNanoSeconds = [defaults integerForKey:LiveCallFilterSeconds];
        deltaNanoSeconds *= 1000000000;
        
        dispatch_queue_t queue = dispatch_queue_create("com.magicpoint.schedule", NULL);
        dispatch_time_t delayNanoSeconds;
        delayNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, deltaNanoSeconds);
        dispatch_after(delayNanoSeconds, queue, ^{
            [self scheduleCallLimitAlert];
        });
    }
}

- (void)scheduleLiveMonitorAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (! [self isCallConnected]) {
        return;
    }

    BOOL monitorLive = [defaults boolForKey:MonitorLiveCallAlarm];
    if (monitorLive) 
    {
        NSString *messageString = NSLocalizedString(@"Open Flip Call Timer?", nil);
        NSDictionary *userInfoNotify = [NSDictionary dictionaryWithObject:
                                        [NSKeyedArchiver archivedDataWithRootObject:messageString] forKey:MonitorLiveCallAlarm];
        
        [self.class notifyNow:messageString userInfo:userInfoNotify];
    }
}

- (void)internalScheduleLiveMonitorAlert
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL monitorLive = [defaults boolForKey:MonitorLiveCallAlarm];
    if (monitorLive) 
    {
        // 11/8 : MonitorLiveFilterSeconds given to user to navigate the voice menu.
        int64_t deltaNanoSeconds = [defaults integerForKey:MonitorLiveFilterSeconds];
        deltaNanoSeconds *= 1000000000;
        dispatch_queue_t queue = dispatch_queue_create("com.magicpoint.schedule", NULL);
        dispatch_time_t delayNanoSeconds;
        delayNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, deltaNanoSeconds);
        dispatch_after(delayNanoSeconds, queue, ^{
            [self scheduleLiveMonitorAlert];
        });
    }
}

- (void)registerCallConnect {
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallConnectedEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kConnectedTime];
         NSString *callID  = [userInfo objectForKey:kCallID];
         
         // 10/14 : handle incoming call ID.
         CallEvent *event = [callDictionary valueForKey:callID];
         if (event) {
             event.connectedTime = [number doubleValue];
         }
         
         [self internalScheduleCallLimitAlert];
         [self internalScheduleLiveMonitorAlert];
     }
     ];
}


- (void)registerCallDisconnect
{
    // dpark: we need to serialize notification delegate block calls.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallDisconnectedEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kDisconnectedTime];
//         self.disconnectedTime = [number doubleValue];
         self.disconnectedCallID  = [userInfo objectForKey:kCallID];
         if (0) {
             NSLog(@"%s:disconnectedCallID:%@", __FUNCTION__, disconnectedCallID);
         }
         
         CallEvent *event = [callDictionary valueForKey:disconnectedCallID];
         if (event) {
             event.disconnectedTime = [number doubleValue];
         }
         
         [self calculateCallUsage];
     }
     ];
}

- (NSTimeInterval)oldestConnectedTime
{
    if ([callDictionary allValues].count == 0) 
    {
        return 0;
    }
    
    NSArray *values = [callDictionary allValues];
    CallEvent *firstEvent = nil;
    
    for (CallEvent *event in values) 
    {
        if (event.connectedTime > 0) 
        {
            if (nil == firstEvent) 
            {
                firstEvent = event;
            }
            else 
            {
                if (event.connectedTime <= firstEvent.connectedTime) 
                {
                    firstEvent = event;
                }
            }
        }
    }
    
    if (nil == firstEvent ) {
        return 0;
    } else {
        return firstEvent.connectedTime;
    }
}

- (BOOL)isCallConnected
{
    if (0) {
        NSLog(@"%s:%lf", __FUNCTION__, [self oldestConnectedTime]);
    }
    
    return [self oldestConnectedTime] > 0;
}

#pragma mark Event Logging

//#define MaxEvents 50
#define MaxEvents 5

- (void)addCallEvent:(NSTimeInterval)eventTime eventName:(NSString*)eventName
{
    // key & value are NSString.
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:eventTime];
    
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               [Formats formatTimestamp:date], eventName,
                               nil];
    
    [events insertObject:eventInfo atIndex:0];
    while ([events count] > MaxEvents) {
        [events removeLastObject];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
                                                        object:self 
                                                      userInfo:nil];
    
    if (0 && 0) {
        NSLog(@"%s:eventName:%@,eventTime:%lf", 
              __FUNCTION__, eventName, eventTime);
    }
}

- (void)registerCallDialingEventLog
{
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallDialingEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kDialingTime];
         [self addCallEvent:[number doubleValue] eventName:kCallDialingEvent];
         
     }
     ];
}

- (void)registerCallIncomingEventLog
{
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallIncomingEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kIncomingTime];
         [self addCallEvent:[number doubleValue] eventName:kCallIncomingEvent];
         
     }
     ];
}

- (void)registerCallConnectEventLog
{
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallConnectedEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kConnectedTime];
         [self addCallEvent:[number doubleValue] eventName:kCallConnectedEvent];
     }
     ];
}

- (void)registerCallDisconnectEventLog
{
    // dpark: so it won't be executed using the posting thread.
    [[NSNotificationCenter defaultCenter] addObserverForName:kCallDisconnectedEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kDisconnectedTime];
         [self addCallEvent:[number doubleValue] eventName:kCallDisconnectedEvent];
     }
     ];
}

- (void)registerUpdatedUsageEventLog
{
    [[NSNotificationCenter defaultCenter] addObserverForName:kUpdatedUsageEvent
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         if (0 && 0) {
             NSLog(@"%s", __FUNCTION__);
         }
         
         NSDictionary *userInfo = notif.userInfo;
         NSNumber *number = [userInfo objectForKey:kCallDuration];
         
         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [Formats minsSeconds:[number integerValue]],
                                    @"Duration",
                                    nil];
         
         [events insertObject:eventInfo atIndex:0];
         [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
                                                             object:self 
                                                           userInfo:nil];
     }
     ];
}

//- (void)registerApplicationActivatedEventLog
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//
//         // 6/22 : systemTimeZone per app may have changed since app resigned active.
//         //      : resetting it here per CalendarComponents
//         [NSTimeZone resetSystemTimeZone];
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [Formats backgroundTimeRemaining], @"UIApplicationDidBecomeActiveNotification",
//                                    nil];
//         
//         [events insertObject:eventInfo atIndex:0];
//         [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
//                                                             object:self 
//                                                           userInfo:nil];
//     }
//     ];
//}


//- (void)registerApplicationWillForegroundEventLog
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [Formats backgroundTimeRemaining], @"UIApplicationWillEnterForegroundNotification",
//                                    nil];
//         
//         [events insertObject:eventInfo atIndex:0];
//         [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
//                                                             object:self 
//                                                           userInfo:nil];
//     }
//     ];
//}


//- (void)registerApplicationBackgroundedEventLog
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [Formats backgroundTimeRemaining], @"UIApplicationDidEnterBackgroundNotification",
//                                    nil];
//         
//         [events insertObject:eventInfo atIndex:0];
//         [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
//                                                             object:self 
//                                                           userInfo:nil];
//     }
//     ];
//}


//- (void)registerApplicationWillTerminateEventLog
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [Formats backgroundTimeRemaining], @"UIApplicationWillTerminateNotification",
//                                    nil];
//         
//         [events insertObject:eventInfo atIndex:0];
//         [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
//                                                             object:self 
//                                                           userInfo:nil];
//     }
//     ];
//}

//- (void)registerApplicationWillResignEventLog
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [Formats backgroundTimeRemaining], @"UIApplicationWillResignActiveNotification",
//                                    nil];
//         
//         [events insertObject:eventInfo atIndex:0];
//         [[NSNotificationCenter defaultCenter] postNotificationName:kLogTableRefreshEvent 
//                                                             object:self 
//                                                           userInfo:nil];
//     }
//     ];
//}

- (void)registerNotifications
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }

    self.serialQueue = [[NSOperationQueue alloc] init];
    [serialQueue setMaxConcurrentOperationCount:1];
    
    
    // 10/14 : distinguish incoming & dialing calls.
    [self registerCallIncoming];
    [self registerCallDialing];
    
    [self registerCallConnect];
    [self registerCallDisconnect];

// Event Logging    
    
    if (!events) {
        self.events = [NSMutableArray arrayWithCapacity:MaxEvents];
    }
    
    [self registerCallIncomingEventLog];
    [self registerCallDialingEventLog];
    [self registerCallConnectEventLog];
    [self registerCallDisconnectEventLog];
    [self registerUpdatedUsageEventLog];
    
//    [self registerApplicationWillResignEventLog];
//    [self registerApplicationWillTerminateEventLog];
//    [self registerApplicationBackgroundedEventLog];
//    [self registerApplicationWillForegroundEventLog];
//    [self registerApplicationActivatedEventLog];
}

+ (void)resetAllMinutes
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    
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
    
    // 11/1 : For those users who still have Show Flip Timer ON.
    //      : Restore it to the default mode OFF.
    [defaults setBool:NO forKey:MonitorLiveCallAlarm];
	[defaults setInteger:60*3 forKey:MonitorLiveFilterSeconds];
}

+ (void)resetLifetime
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:LifeMinutesUsed];
}


- (void)configure {
    ushort capacity = 4;
    
    if (! connectedCallSet) {
        self.connectedCallSet = [NSMutableSet setWithCapacity:capacity];
    }
    if (! callDictionary) {
        self.callDictionary = [NSMutableDictionary dictionaryWithCapacity:capacity];
    }
    
    [self registerNotifications];
    
}

- (id)init
{
    self = [super init];
    if (self) {
        [self configure];
    }
    
    return self;
}

static StatsManager *singleton;
+ (StatsManager *)sharedInstance
{
    if (! singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          singleton = [[StatsManager alloc] init];
                      });
    }
    return singleton;
}

@end
