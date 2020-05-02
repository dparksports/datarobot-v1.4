//
//  MGDataManager.h
//  Data Robot
//
//  Created by Dan Park on 6/6/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MGCurrentBillPeriod;
@interface MGDataManager : NSObject
{
    volatile u_int64_t sentWifiInOctets, receivedWifiInOctets;
    volatile u_int64_t sentWanInOctets, receivedWanInOctets;
}
@property (nonatomic, strong) NSDateFormatter *shortTimeFormatter;
@property (nonatomic, retain) NSNumber *dataReceivedInMB, *dataSentInMB;
@property (nonatomic, retain) NSMutableDictionary *bootTimes;
@property (nonatomic, strong) MGCurrentBillPeriod *currentBillPeriod;

+ (id)sharedInstance;

- (NSString*)stringFromMediumTimeFormatter:(NSDate*)date;
- (void)loadBootTimeUsages;
- (void)saveBootTimeUsages;

//- (void)increaseAccelerometerFrequency;
- (void)sampleUsageAndUpdateRecords;
- (BOOL)clearAndSaveBootTimeUsageIfNewPeriod;

//- (void)startAccelerometer;
//- (NSTimeInterval)directTimestampByAccelerator;
//- (NSTimeInterval)deltaBetweenSamples;
- (NSTimeInterval)uptimeByKernel;

- (float)nonAdjustedCurrentDataUsageInFloat;
- (float)adjustedCurrentDataUsageInFloat;

- (NSString*)readableUsageIn64Unit:(int64_t)bytes;
- (NSString*)maskStringForDataUsage;
- (NSString*)maskStringForDataUsage:(float)usedDataInUnit;
- (NSString*)currentPeriodUsageString;
- (NSString*)currentPeriodUsageStringWith:(float)usedDataInUnit;
- (CGFloat)usedDataInPercentile;

- (void)saveTodayInBillRecord;
- (void)loadCurrentBillPeriod;
- (void)updateDataQuotaInMB:(NSUInteger)quotaInMB;
- (void)updateCurrentBillPeriod:(NSUInteger)resetDay;
- (void)updateCurrentBillPeriodWithAdjustedDataUsage:(float)usedDataInMB;
- (void)saveCurrentBillPeriod;

- (void)sampleNetworkInterfaces;
- (u_int64_t)receivedWifiInUnit;
- (u_int64_t)sentWifiInUnit;
- (u_int64_t)receivedWANInUnit;
- (u_int64_t)sentWANInUnit;

@end
