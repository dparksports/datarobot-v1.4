//
//  MGCurrentBillPeriod.h
//  Data Robot
//
//  Created by Dan Park on 6/9/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGCurrentBillPeriod : NSObject
//@property (nonatomic, strong) NSNumber *yearOfLastAnchor;
//@property (nonatomic, strong) NSNumber *monthOfLastAnchor;
//@property (nonatomic, strong) NSNumber *dayOfLastAnchor;
@property (nonatomic, strong) NSDate *lastAnchoredDate;

@property (nonatomic, strong) NSNumber *billDayOfMonth;
@property (nonatomic, strong) NSNumber *dataQuotaInMB;
@property (nonatomic, strong) NSNumber *adjustedDataUsageInMB;
- (NSDate*)lastAnchoredDateFromBillRecord;
- (NSDate*)resetDateOfThisMonth;
- (NSDate*)resetDateOfNextMonth;
- (NSInteger)daysToReset;

+ (NSInteger)yearOfToday;
+ (NSInteger)monthOfToday;
+ (NSInteger)dayOfToday;

@end
