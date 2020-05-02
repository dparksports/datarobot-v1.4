//
//  LocationManager.m
//  DetectRegion
//
//  Created by Dan Park on 7/13/11.
//  Copyright 2011 MAGIC POINT. All rights reserved.
//

#import "LocationManager.h"

#import "NotificationManager.h"
#import "UserDefaults.h"
#import "CalendarComponents.h"
#import "Formats.h"


@implementation LocationManager
@synthesize regionRadius;
@synthesize locationManager;
@synthesize lastUpdatedLocation;

static LocationManager *singleton = nil;
+ (LocationManager *)sharedInstance 
{
	if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          singleton = [[[self class] alloc] init];
                      });
	}

//	if (!singleton) {
//		singleton = [[[self class] alloc] init];
//	}
	return singleton;
}

- (NSString*)formatTimeOnly:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterLongStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}


- (void)checkRegionMonitoring {
    if (![CLLocationManager regionMonitoringAvailable]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Unsupported" message: @"Sorry, this device cannot create GeoFence reminders." delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)addRegion:(CLLocationDistance)radius
{
    static ushort regionCount = 0;
    NSSet *regions = [locationManager monitoredRegions];
    NSString *regionId = [NSString stringWithFormat:@"rId:%d", regionCount];
    
    CLLocation *location = locationManager.location;
    CLLocationCoordinate2D coordinate = location.coordinate;
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coordinate
                                                               radius:radius
                                                           identifier:regionId];
//    [locationManager startMonitoringForRegion:region desiredAccuracy:kCLLocationAccuracyHundredMeters]; // was 100 meters
    [locationManager startMonitoringForRegion:region desiredAccuracy:kCLLocationAccuracyThreeKilometers];
    
    NSString *radiusString = [NSString stringWithFormat:@"region %4.0f %d/%d %@", 
                              radius, regionCount++, [regions count], 
                              [self formatTimeOnly:location.timestamp]];
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:radiusString];
}

- (void)startCascadingRegions
{
    // 7/16 : only 10 regions are accepted.
    dispatch_queue_t queue = dispatch_queue_create("com.magicpoint.locationmanager", NULL);
    dispatch_async(queue, ^{
        [self addRegion:3000];
    });
    dispatch_async(queue, ^{
        [self addRegion:2000];
    });
    dispatch_async(queue, ^{
        [self addRegion:1000];
    });
    dispatch_async(queue, ^{
        [self addRegion:500];
    });
    dispatch_async(queue, ^{
        [self addRegion:250];
    });
    dispatch_async(queue, ^{
        [self addRegion:100];
    });
    dispatch_async(queue, ^{
        [self addRegion:50];
    });
    dispatch_async(queue, ^{
        [self addRegion:10];
    });
    dispatch_async(queue, ^{
        [self addRegion:5];
    });
    dispatch_async(queue, ^{
        [self addRegion:1];
    });
//    dispatch_release(queue);
}

- (void)startRegionMonitoring
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    [self checkRegionMonitoring];
    
    CLLocation *location = locationManager.location;
    if (location) 
    {
        dispatch_queue_t queue = dispatch_queue_create("com.magicpoint.locationmanager", NULL);
        dispatch_async(queue, ^
        {
            [self startCascadingRegions];
        });
    }
    else 
    {
        NotificationManager *notificationManager = [NotificationManager sharedInstance];
        [notificationManager addTimestampedEvent:@"strRM:NA deviceLocation"];
    }
}


- (void)stopRegionMonitoring
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
	NSSet *regions = [locationManager monitoredRegions];
    
    NSEnumerator *enumerator = [regions objectEnumerator];
    CLRegion *region;
    
    while ((region = [enumerator nextObject])) {
        [locationManager stopMonitoringForRegion:region];
    }
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"stopRM"];
}

- (void)startMonitoring
{
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"startMonitoring"];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) 
    {
        [locationManager startMonitoringSignificantLocationChanges];
    } 
    else 
    {
        NotificationManager *notificationManager = [NotificationManager sharedInstance];
        [notificationManager addTimestampedEvent:@"NA significantLocationChangeMonitoring"];
    }
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
}

- (void)stopMonitoring
{
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"stopMonitoring"];
    
    [locationManager stopMonitoringSignificantLocationChanges];
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
}

//- (void)startGPSMonitoring
//{
//    if (0) {
//        NSLog(@"%s", __FUNCTION__);
//    }
//    
//    NotificationManager *notificationManager = [NotificationManager sharedInstance];
//    [notificationManager addTimestampedEvent:@"startGPSMonitoring"];
//    
////    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//    [locationManager startUpdatingLocation];
//}
//
//- (void)stopGPSMonitoring
//{
//    if (0) {
//        NSLog(@"%s", __FUNCTION__);
//    }
//    
//    NotificationManager *notificationManager = [NotificationManager sharedInstance];
//    [notificationManager addTimestampedEvent:@"stopGPSMonitoring"];
//    
//    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//    [locationManager stopUpdatingLocation];
//}

//#define deviceRadius 1000
#define deviceRadius 500

- (id)init {
	if ((self = [super init])) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.purpose = NSLocalizedString(@"It uses the location service to track your call locations on a map.", nil);
		locationManager.delegate = self;
        regionRadius = deviceRadius;
        if ([locationManager respondsToSelector:@selector(setPausesLocationUpdatesAutomatically:)]) {
            [locationManager setPausesLocationUpdatesAutomatically:NO];
        }
        if ([locationManager respondsToSelector:@selector(setActivityType:)]) {
//            [locationManager setActivityType:CLActivityTypeOther];  // iOS 6: battery consumption high
            [locationManager setActivityType:CLActivityTypeFitness];
        }
	}
	return self;
}

+ (void)verifyDisabledLocationService {
    static UIAlertView *disabledLocationAlertView = nil;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (kCLAuthorizationStatusAuthorized != [CLLocationManager authorizationStatus]) {
            if (! disabledLocationAlertView) {
                disabledLocationAlertView = [[UIAlertView alloc] initWithTitle:@"Location Service"
                                                                    message:@"The location service is Off for this app.  Please turn it On in Settings."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil
                                          ];
                [disabledLocationAlertView show];
            } else {
                if (! disabledLocationAlertView.visible) {
                    [disabledLocationAlertView show];
                }
            }
        }
    });
}

+ (void)scheduleNotify:(NSDate*)fireDate userInfo:(NSDictionary*)userInfo alert:(NSString*)alertBody {
    [NSTimeZone resetSystemTimeZone];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    
    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
    
	UILocalNotification *notify = [[UILocalNotification alloc] init];
    notify.timeZone = systemTimeZone;
    notify.fireDate = fireDate;
    notify.alertAction = @"Open";
    notify.soundName = UILocalNotificationDefaultSoundName;
	notify.userInfo = userInfo;
    notify.alertBody = alertBody;
    
    [application scheduleLocalNotification:notify];
}

+ (void)scheduleCycleReset:(NSDate*)fireDate
{
    NSString *message = NSLocalizedString(@"You have new full minutes, today!", nil);
    NSString *alertBody = [NSString stringWithFormat:@"%@", message];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
     [NSKeyedArchiver archivedDataWithRootObject:message] forKey:ResetBillingCycle];
    
    [self.class scheduleNotify:fireDate userInfo:userInfo alert:alertBody];
}

#pragma mark CLLocationManagerDelegate


- (void)notifyLocally:(NSString*)message
{
    UIApplication *application = [UIApplication sharedApplication];
    
    NSTimeInterval maxInterval = application.backgroundTimeRemaining;
    
//    int maxInt = maxInterval;
//    NSString *maxString =  (maxInterval >= MAXFLOAT) 
//    ? [NSString stringWithFormat:@"%d", -1] 
//    : [NSString stringWithFormat:@"%d", maxInt];
    
    NSString *maxString =  (maxInterval >= MAXFLOAT) 
    ? [NSString string] 
    : @"max";

	UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertAction = @"Open";
    note.soundName = UILocalNotificationDefaultSoundName;
    note.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
	note.userInfo = [NSDictionary dictionaryWithObject:
                     [NSKeyedArchiver archivedDataWithRootObject:message] forKey:@"LocationManager"];

    switch (application.applicationState) 
    {
        case UIApplicationStateActive:
            maxString = (0) ? [NSString string] : [NSString stringWithFormat:@"[%@:f]", maxString];
            break;
        case UIApplicationStateInactive:
            maxString = (0) ? [NSString string] : [NSString stringWithFormat:@"[%@:i]", maxString];
            break;
        case UIApplicationStateBackground:
            maxString = (0) ? [NSString string] : [NSString stringWithFormat:@"[%@:b]", maxString];
            break;
        default:
            maxString = (0) ? [NSString string] : [NSString stringWithFormat:@"[%@:d]", maxString];
            break;
    }

    note.alertBody = [NSString stringWithFormat:@"%@\n%@", message, maxString];
    [application presentLocalNotificationNow:note];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"didChangeAuthorizationStatus"];
//    [self notifyLocally:@"didChangeAuthorizationStatus"];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region 
{
    if (0) {
        NSLog(@"%s:%@", __FUNCTION__, region);
    }
    NSString *regionString = [NSString stringWithFormat:@"eRG:r:%4.0f,%@",
                              region.radius,region.identifier];
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:regionString];
//    [self notifyLocally:@"didEnterRegion"];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region 
{
    if (0) {
        NSLog(@"%s:%@", __FUNCTION__, region);
    }
    NSString *regionString = [NSString stringWithFormat:@"xRG:r:%4.0f,%@",
                              region.radius,region.identifier];
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:regionString];
//    [self notifyLocally:@"didExitRegion"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (0) {
        NSLog(@"%s:error:%@", __FUNCTION__, error);
    }
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"didFailWithError"];
    if (0 && 0) {
        [self notifyLocally:@"didFailWithError"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"didStartMonitoringForRegion"];
    [self notifyLocally:@"didStartMonitoringForRegion"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"didUpdateHeading"];
    [self notifyLocally:@"didUpdateHeading"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    
    self.lastUpdatedLocation = newLocation;
    
    NSString *updateString = [NSString stringWithFormat:@"udLoc:accH:%4.0f,%2.1f",
                              newLocation.horizontalAccuracy,newLocation.speed];
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:updateString];
//    [self notifyLocally:@"didUpdateToLocation"];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error 
{
    if (0) {
        NSLog(@"%s:%@:error:%@", __FUNCTION__, region, error);
    }
    NSString *regionString = [NSString stringWithFormat:@"mfRG:r:%4.0f,%@",
                              region.radius,region.identifier];
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:regionString];
//    [self notifyLocally:@"monitoringDidFailForRegion"];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    NotificationManager *notificationManager = [NotificationManager sharedInstance];
    [notificationManager addTimestampedEvent:@"ShouldDisplayHeadingCalibratio"];
    [self notifyLocally:@"ShouldDisplayHeadingCalibration"];
    return YES;
}

- (void)activateLocationManager:(NSString*)message doNotify:(BOOL)notify
{
    if (0) {
        NSLog(@"%s", __FUNCTION__);
    }
    
    LocationManager *manager = [[self class] sharedInstance];
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
    if (0) {
        NSLog(@"%s", __FUNCTION__);
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            [self activateLocationManager:@"locationManagerDidResumeLocationUpdates" doNotify:YES];
        }
    }
}
@end
