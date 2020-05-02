//
//  StatsManager.h
//  S3
//
//  Created by Dan Park on 5/19/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kLogTableRefreshEvent;
extern NSString *kUpdatedUsageEvent;	 
extern NSString *kCallDuration;	 

@interface StatsManager : NSObject
{
    NSOperationQueue *serialQueue;
    NSInteger lastCallSeconds;
//    NSInteger spillOverSeconds;
    
//    NSTimeInterval disconnectedTime;
    NSString *disconnectedCallID;

    NSMutableSet *connectedCallSet;
    NSMutableDictionary *callDictionary;
    NSUInteger connectedCount;
    
    NSMutableArray *events;
    
//    BOOL savedUsedMinutes;
}
@property (nonatomic, retain) NSMutableArray *events;

@property (nonatomic, retain) NSOperationQueue *serialQueue;

//@property (nonatomic, assign) NSTimeInterval disconnectedTime;
@property (nonatomic, copy) NSString *disconnectedCallID;
@property (nonatomic, retain) NSMutableSet *connectedCallSet;
@property (nonatomic, retain) NSMutableDictionary *callDictionary;


+ (StatsManager *)sharedInstance;
+ (void)scheduleAlarmForDate:(NSDate*)now withMessage:(NSString*)message;


+ (void)resetAllMinutes;
+ (void)resetLifetime;

- (NSTimeInterval)oldestConnectedTime;
- (BOOL)isCallConnected;

@end
