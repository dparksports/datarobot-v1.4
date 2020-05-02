//
//  LocationManager.h
//  DetectRegion
//
//  Created by Dan Park on 7/13/11.
//  Copyright 2011 MAGIC POINT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject
<CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocation *lastUpdatedLocation;
@property (nonatomic, assign) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationDistance regionRadius;

+ (LocationManager *)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;

- (void)notifyLocally:(NSString*)message;
+ (void)scheduleCycleReset:(NSDate*)fireDate;
+ (void)scheduleNotify:(NSDate*)fireDate userInfo:(NSDictionary*)userInfo alert:(NSString*)alertBody;
+ (void)verifyDisabledLocationService;

- (void)stopRegionMonitoring;
- (void)startRegionMonitoring;

//- (void)startGPSMonitoring;
//- (void)stopGPSMonitoring;


@end
