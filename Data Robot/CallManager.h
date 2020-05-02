//
//  CallManager.h
//  S3
//
//  Created by Dan Park on 5/19/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

extern NSString *kDisabledLocationServiceEvent;	 

extern NSString *kCallConnectedEvent;	 
extern NSString *kCallDisconnectedEvent;	 
extern NSString *kCallDialingEvent;	 
extern NSString *kCallIncomingEvent;	 

extern NSString *kDialingTime;	 
extern NSString *kIncomingTime;	 
extern NSString *kConnectedTime;	 
extern NSString *kDisconnectedTime;	

extern NSString *kCallID;	 


@interface CallManager : NSObject
<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    
    CTTelephonyNetworkInfo *telephonyNetworkInfo;
	CTCallCenter *callCenter;

    
    NSTimeInterval connectedTime, disconnectedTime;
    NSTimeInterval incomingCallTime, dialingTime;
    
    NSString *connectedCallID, *disconnectedCallID;
    NSString *incomingCallID, *dialingCallID;
    
}
//@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) CTTelephonyNetworkInfo *telephonyNetworkInfo;
@property (nonatomic, retain) CTCallCenter *callCenter;
//@property (nonatomic, retain) NSTimer *callTimer;
@property (nonatomic, retain) NSMutableSet *connectedCTCalls;
@property (nonatomic, retain) NSMutableSet *callTimers;

@property (nonatomic, assign) NSTimeInterval connectedTime, disconnectedTime;
@property (nonatomic, assign) NSTimeInterval incomingCallTime, dialingTime;

@property (nonatomic, copy) NSString *connectedCallID, *disconnectedCallID;
@property (nonatomic, copy) NSString *incomingCallID, *dialingCallID;

+ (CallManager *)sharedInstance;
//- (void)startUpdatingLocation;
//- (void)stopUpdatingLocation;

@end
