//
//  CallManager.m
//  S3
//
//  Created by Dan Park on 5/19/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "CallManager.h"
#import "LocationManager.h"
#import "UserDefaults.h"

NSString *kDisabledLocationServiceEvent = @"kDisabledLocationServiceEvent";	 

NSString *kCallConnectedEvent = @"kCallConnectedEvent";	 
NSString *kCallDisconnectedEvent = @"kCallDisconnectedEvent";	 
NSString *kCallDialingEvent = @"kCallDialingEvent";	 
NSString *kCallIncomingEvent = @"kCallIncomingEvent";	 

NSString *kDialingTime = @"kDialingTime";	 
NSString *kIncomingTime = @"kIncomingTime";	 
NSString *kConnectedTime = @"kConnectedTime";	 
NSString *kDisconnectedTime = @"kDisconnectedTime";	 

NSString *kCallID = @"kCallID";	 

@implementation CallManager

@synthesize callCenter, telephonyNetworkInfo;
@synthesize connectedTime, disconnectedTime;
@synthesize incomingCallTime, dialingTime;

@synthesize connectedCallID, disconnectedCallID;
@synthesize incomingCallID, dialingCallID;

- (void)restoreDesiredAccuracy
{
    // 9/26 : set better desired accuracy at 3 KM.
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
}

- (void)optimizeDesiredAccuracy
{
    // 11/7/12 : iOS 6: consumes battery too fast.
    //    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (void)stopLocationManager
{
    if (locationManager) 
    {
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        locationManager = nil;
        
        if (1 && 0) {
            NSLog(@"%s", __FUNCTION__);
        }
    }
}

- (void)startLocationManager
{
    if (!locationManager) 
    {
        // dpark: self.locationManager removed
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        
        if ([locationManager respondsToSelector:@selector(setPausesLocationUpdatesAutomatically:)]) {
            [locationManager setPausesLocationUpdatesAutomatically:NO];
        }
        if ([locationManager respondsToSelector:@selector(setActivityType:)]) {
            // CLActivityTypeOther: battery consumption high
            [locationManager setActivityType:CLActivityTypeFitness];
        }
        
        // 11/7/12: iOS 6: 12 hours test consumes almost no battery.
        locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
        locationManager.purpose = @"It shows your location on a map when you make or receive a call.";
        
        // dpark: 1 KM (uses Cell towers in a cluster every 500 to 1000 meters.
        // 6/8/11: at&t iphone batt dropped to 39% from 91% in 6 hrs
        //        locationManager.distanceFilter = 1000; // 1000 meters (1 KM)
        //        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        
        //// dpark: cell tower use only? (wifi off)
        //// dpark: batt usage: 96% in 2 hrs (3:15/100% -> 5:30/96)
        //        locationManager.distanceFilter = 3000; // 1000 meters (1 KM)
        //        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        [self restoreDesiredAccuracy];
        
        // 11/7/12: signification location change doesn't register call events in background.
//        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];
        if (1 && 0) {
            NSLog(@"%s", __FUNCTION__);
        }

    }
}

//- (void)stopUpdatingLocation{
//    [locationManager stopUpdatingLocation];
//}
//
//- (void)startUpdatingLocation{
//    [locationManager startUpdatingLocation];
//}



- (void)dialingCall
{
    if (0 && 0) {
        NSLog(@"%s:dialingTime:%lf, dialingCallID:%@", 
              __FUNCTION__, dialingTime, dialingCallID);
    }
    
    // dpark: need Remote IO AU to background CTCallCenter
    // dpark: temporary disabled to test GPS alone
//    [self startLocationManager];
    
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:dialingTime], kDialingTime,
                              dialingCallID, kCallID,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDialingEvent 
                                                        object:self 
                                                      userInfo:userInfo];
}

- (void)incomingCall
{
    if (0 && 0) {
        NSLog(@"%s:incomingCallTime:%lf, incomingCallID:%@", 
              __FUNCTION__, incomingCallTime, incomingCallID);
    }

    // dpark: need Remote IO AU
//    [self startLocationManager];

    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:incomingCallTime], kIncomingTime,
                              incomingCallID, kCallID,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallIncomingEvent 
                                                        object:self 
                                                      userInfo:userInfo];
}

- (void)connectedCall
{
    if (0 && 0) {
        NSLog(@"%s:connectedTime:%lf, connectedCallID:%@", 
              __FUNCTION__, connectedTime, connectedCallID);
    }
    
    // dpark: need Remote IO AU
    // dpark: temporary disabled to test GPS alone
//    [self stopLocationManager];
    
    [self optimizeDesiredAccuracy];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:connectedTime], kConnectedTime,
                              connectedCallID,kCallID,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallConnectedEvent 
                                                        object:self 
                                                      userInfo:userInfo];
}

- (void)disconnectedCall
{
    if (0 && 0) {
        NSLog(@"%s:disconnectedTime:%lf, disconnectedCallID:%@", 
              __FUNCTION__, disconnectedTime, disconnectedCallID);
    }
    
    [self optimizeDesiredAccuracy];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:disconnectedTime], kDisconnectedTime,
                              disconnectedCallID, kCallID,
                              nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDisconnectedEvent 
                                                        object:self 
                                                      userInfo:userInfo];
}

- (void)registerCallCenter
{
    if (! callCenter) {
        self.callCenter = [[CTCallCenter alloc] init];
        if (0) {
            NSLog(@"%s", __FUNCTION__);
        }
    }
    
    callCenter.callEventHandler = ^(CTCall *call) { 
        if (1 && 0) {
            NSLog(@"%s:callState:%@", __FUNCTION__, call.callState);
        }
        
        if (call.callState == CTCallStateDisconnected) {
            disconnectedTime = [NSDate timeIntervalSinceReferenceDate];
            self.disconnectedCallID = call.callID;
            [self disconnectedCall];
            [self.connectedCTCalls removeObject:call.callID];
            NSLog(@"CTCallStateDisconnected:connectedCTCalls count:%d", [self.connectedCTCalls count]);
        }
        if (call.callState == CTCallStateConnected) {
            connectedTime = [NSDate timeIntervalSinceReferenceDate];
            self.connectedCallID = call.callID;
            [self connectedCall];
            [self.connectedCTCalls addObject:call.callID];
            NSTimer *timer = [NSTimer timerWithTimeInterval:10.0
                                                     target:self
                                                   selector:@selector(verifyCallState:)
                                                   userInfo:(id) call.callID
                                                    repeats:YES];
            NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
            [mainRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
            [self.callTimers addObject:timer];
            NSLog(@"CTCallStateConnected: connectedCTCalls count:%d", [self.connectedCTCalls count]);
            NSLog(@"CTCallStateConnected: callTimers count:%d", [self.callTimers count]);
        }
        if (call.callState == CTCallStateIncoming) {
            incomingCallTime = [NSDate timeIntervalSinceReferenceDate];
            self.incomingCallID = call.callID;
            [self incomingCall];
        }
        if (call.callState == CTCallStateDialing) {
            dialingTime = [NSDate timeIntervalSinceReferenceDate];
            self.dialingCallID = call.callID;
            [self dialingCall];
        }
        
	};
}

- (void)settingsChanged:(NSNotification*)notification
{
	BOOL isMonitoringLocation = [[NSUserDefaults standardUserDefaults] boolForKey:MonitorLocation];
    if (0 && 0) {
        NSLog(@"%s:%@:%@", __FUNCTION__,
              MonitorLocation, [UserDefaults yesOrNo:isMonitoringLocation]);
    }

// 6/15: disabling this code to remove monitor location switch to avoid user confusion.    
//	if (isMonitoringLocation) {
//		[locationManager startUpdatingLocation];
//	} else {
//		[locationManager stopUpdatingLocation];
//	}
}

- (void)registerUserDefaultNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)verifyCallState:(NSTimer*)timer{
    BOOL foundCallID = NO;
    NSString *callerID = (NSString*) [timer userInfo];
    NSSet *currentCalls = [self.callCenter currentCalls];
    if (currentCalls) {
        NSSet *connectedCalls = [currentCalls copy];
        NSLog(@"%s: connectedCalls count:%d", __func__, [connectedCalls count]);
        NSEnumerator *enumerator = [connectedCalls objectEnumerator];
        CTCall *call;
        
        while ((call =  (CTCall *) [enumerator nextObject])) {
            if ([[call callID] isEqualToString:callerID]) {
                foundCallID = YES;
                break;
            }
        }
    }
    
    if (! foundCallID) {
        if ([self.connectedCTCalls member:callerID]) {
            disconnectedTime = [NSDate timeIntervalSinceReferenceDate];
            self.disconnectedCallID = callerID;
            [self disconnectedCall];
            
            [self.connectedCTCalls removeObject:callerID];
            NSLog(@"%s:connectedCTCalls count:%d", __func__, [self.connectedCTCalls count]);
            LocationManager *manager = [LocationManager sharedInstance];
            [manager startMonitoring];
            [manager notifyLocally:@"Stale Call Disconnected."];
        }
        
        [self.callTimers removeObject:timer];
        [timer invalidate];
        NSLog(@"%s: callTimers count:%d", __func__, [self.callTimers count]);
    }
}

//- (void)verifyCallState:(NSTimer*)timer{
//    NSUInteger count = [self.connectedCTCalls count];
//    NSMutableArray *disconnectedCalls = [NSMutableArray arrayWithCapacity:count];
//    for (CTCall *call in self.connectedCTCalls) {
//        if ([call.callState isEqualToString: CTCallStateDisconnected]) {
//            [disconnectedCalls addObject:call];
//        }
//    }
//    
//    for (CTCall *call in disconnectedCalls) {
//        disconnectedTime = [NSDate timeIntervalSinceReferenceDate];
//        self.disconnectedCallID = call.callID;
//        [self disconnectedCall];
//    }
//    
//    [self.connectedCTCalls removeObjectsInArray:disconnectedCalls];
//}

- (void)configure {
    // dpark: needed without Remote IO AU
    // dpark: enables CTCallCenter in background.
    [self registerCallCenter];
    
// dpark: need to ask the user for the GPS permission.    
    [self startLocationManager];
    
// dpark: don't stop Location Manager
//    [self performSelector:@selector(stopLocationManager) withObject:nil afterDelay:5];
    
    [self registerUserDefaultNotification];
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:10];
    [self setConnectedCTCalls:set];
    
    set = [NSMutableSet setWithCapacity:10];
    [self setCallTimers:set];
    
//    NSTimeInterval interval = 1.0; //
//    SEL sel = @selector(verifyCallState:);
//    id userInfo = nil;
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval
//                                                      target:self
//                                                    selector:sel
//                                                    userInfo:userInfo
//                                                     repeats:YES];
//    [self setCallTimer:timer];
}

- (id)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    
    return self;
}

static CallManager *singleton;
+ (CallManager *)sharedInstance
{
    if (! singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          if (0) {
                              NSLog(@"%s:instantion", __FUNCTION__);
                          }
                          singleton = [[CallManager alloc] init];
                      });
    }

//    if (! singleton) {
//        singleton = [[[CallManager alloc] init] retain];
//    }
    return singleton;
}


#pragma mark CLLocationManagerDelegate

+ (void)alertMessage:(NSString*)message title:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+ (void)alertAllLocationServicesDisabled
{
    if (CLLocationManager.locationServicesEnabled == NO) 
    {
//        [self.class alertMessage:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." title:@"Location Services Disabled"];
        [self.class alertMessage:@"You currently have all location services for this device disabled. Please enable it in Settings." title:@"Location Services Disabled"];
    }
}

+ (void)alertLocationDisabled
{
    [self.class alertMessage:@"You currently have the location service for this app disabled. Please enable it in Settings." title:@"Location Service Disabled"];
//    [self.class alertMessage:@"You currently have the location service for this app disabled. This app works only when the location service is turned ON.  Please enable it in Settings." title:@"Location Service Disabled"];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s", __FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    switch (error.code) {
        case kCLErrorDenied:
//            [self.class alertLocationDisabled];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:MonitorLocation];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDisabledLocationServiceEvent
                                                                object:self 
                                                              userInfo:nil];
            
            return;
        case kCLErrorLocationUnknown:
        {
            [self.class alertMessage:@"Device is in an area where location cannot be determined, temporarily." title:@"Location Services"];
        }
            return;
    }
    
    [self.class alertMessage:[NSString stringWithFormat:@"%@:%d",error.localizedDescription,error.code] title:@"Location Services"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)activateLocationManager:(NSString*)message doNotify:(BOOL)notify
{
    NSLog(@"%s", __FUNCTION__);
    
    LocationManager *manager = [LocationManager sharedInstance];
    [manager startMonitoring];
    
    if (notify) {
        [manager notifyLocally:message];
    }
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    if (0) {
        NSLog(@"%s", __FUNCTION__);
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            [self activateLocationManager:@"locationManagerDidPauseLocationUpdates" doNotify:YES];
        }
    }
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"%s", __FUNCTION__);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        [self activateLocationManager:@"locationManagerDidResumeLocationUpdates" doNotify:YES];
    }
}
@end
