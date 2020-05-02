//
//  CallHistory.h
//  S8
//
//  Created by Dan Park on 7/21/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *HMCallPeriod;
extern NSString *HMCallStart;
extern NSString *HMCallEnd;
extern NSString *HMCallSeconds;
extern NSString *HMCallLat;
extern NSString *HMCallLong;

@interface HistoryManager : NSObject
{
    NSMutableArray *events;
    CLLocationCoordinate2D coordinate;
    BOOL updatedCoordinate; 
}
@property (nonatomic, strong) NSMutableArray *events;

+ (HistoryManager *)sharedInstance;

- (void)addCallEvent:(NSString*)callPeriod callStart:(NSTimeInterval)startTime callEnd:(NSTimeInterval)endTime duration:(NSInteger)usedSeconds;

- (void)saveEmptyProperyList;
- (void)saveProperyList;
- (void)loadProperyList;
- (void)unloadEvents;
- (void)updateCoordinate:(CLLocationCoordinate2D) newCoordinate;


@end
