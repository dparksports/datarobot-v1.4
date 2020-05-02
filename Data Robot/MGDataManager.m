//
//  MGDataManager.m
//  Data Robot
//
//  Created by Dan Park on 6/6/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
#include <mach/mach_time.h>
#include <sys/sysctl.h>

#import "MGDataManager.h"
#import "MGDataUsageObject.h"
#import "MGCurrentBillPeriod.h"

@interface MGDataManager ()
//@property (atomic, readwrite) NSTimeInterval secondsSinceBootByAccelerometer;
//@property (atomic, readwrite) NSTimeInterval secondsSinceBootVerify;
@property (atomic, readwrite) NSTimeInterval secondsSinceBootByKernel;
@property (nonatomic, strong) NSMutableDictionary *usedMonths;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *accelerometerQueue;
@end

@implementation MGDataManager


- (void)dealloc
{
    [self setBootTimes:nil];
    [self setUsedMonths:nil];
}

+ (id)sharedInstance {
    static id singleton;
    if (! singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
                          Class class = [self class];
                          singleton = [[class alloc] init];
                      });
    }
    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUInteger capacity = 30; // assumption: rebooted once a day
        NSMutableDictionary *array = [NSMutableDictionary dictionaryWithCapacity:capacity];
        [self setBootTimes:array];
        
        NSUInteger months = 12;
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:months];
        [self setUsedMonths:dictionary];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [self setShortTimeFormatter:dateFormatter];
    }
    return self;
}

- (NSString*)stringFromShortTimeFormatter:(NSDate*)currentDate {
    [self.shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *string = [self.shortTimeFormatter stringFromDate:currentDate];
#ifdef DEBUG0
    NSLog(@"%s: %@", __FUNCTION__, string);
#endif
    return string;
}

- (NSString*)stringFromMediumTimeFormatter:(NSDate*)currentDate {
    [self.shortTimeFormatter setTimeStyle:NSDateFormatterMediumStyle];
    //    [self.shortTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *string = [self.shortTimeFormatter stringFromDate:currentDate];
    return string;
}

- (NSTimeInterval)uptimeByKernel
{
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    
    (void)time(&now);
    int error = sysctl(mib, 2, &boottime, &size, NULL, 0);
    if (error != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }
    
    NSTimeInterval secondsSinceBoot = uptime;
    [self setSecondsSinceBootByKernel:secondsSinceBoot];
    return secondsSinceBoot;
}

- (NSDate*)uptimeInDate
{
    NSTimeInterval secondsSinceLastBoot = [self uptimeByKernel] * -1;
    NSDate *today = [NSDate date];
    NSDate *bootTime = [today dateByAddingTimeInterval:secondsSinceLastBoot];
#ifdef DEBUG
    NSString *dateString = [self stringFromMediumTimeFormatter:bootTime];
    NSLog(@"%s: uptimeInDate:%@", __FUNCTION__, dateString);
#endif    
    return bootTime;
}

//- (NSTimeInterval)deltaBetweenSamples
//{
//    NSTimeInterval timestamp = [self secondsSinceBootByAccelerometer];
//    NSTimeInterval oldTimestamp = [self secondsSinceBootVerify];
//    NSTimeInterval delta = timestamp - oldTimestamp;
//#ifdef DEBUG
//    NSLog(@"%s: oldTimestamp:%.2f, timestamp:%.2f %.2f", __FUNCTION__,
//          oldTimestamp, timestamp, delta);
//#endif
//    return delta;
//}

//- (NSTimeInterval)directTimestampByAccelerator
//{
//    // 7/13/13: boot time returned drifts over multiple samples. Switching to the kernel uptime.
//    if (self.motionManager) {
//        CMAccelerometerData *data = [self.motionManager accelerometerData];
//        CMLogItem *logItem = (CMLogItem *) data;
//        NSTimeInterval timestamp = [logItem timestamp];
//        NSTimeInterval oldTimestamp = [self secondsSinceBootByAccelerometer];
//        [self setSecondsSinceBootVerify:oldTimestamp];
//        [self setSecondsSinceBootByAccelerometer:timestamp];
//#ifdef DEBUG
//        NSLog(@"%s: boot time secs: %.3f", __FUNCTION__,
//              _secondsSinceBootByAccelerometer);
//#endif
//        return self.secondsSinceBootByAccelerometer;
//    } else {
//#ifdef DEBUG
//        NSLog(@"%s: boot time secs: %.3f - ERROR: NO Motion Manager", __FUNCTION__,
//              _secondsSinceBootByAccelerometer);
//#endif
//        return self.secondsSinceBootByAccelerometer;
//    }
//}

- (void)startAccelerometer
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    if (! self.motionManager) {
        NSInteger semaphore = 1;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:semaphore];
        [self setAccelerometerQueue:queue];
        CMMotionManager *manager = [[CMMotionManager alloc] init];
        [self setMotionManager:manager];
    }
    if ([self.motionManager isAccelerometerAvailable]) {
        [_motionManager startAccelerometerUpdates];
    }
}

- (NSDate*)rawBootTimeByKernel
{
    NSDate *today = [NSDate date];
    [self uptimeByKernel];
    NSTimeInterval secondsSinceLastBoot = [self secondsSinceBootByKernel] * -1;
    NSDate *bootTime = [today dateByAddingTimeInterval:secondsSinceLastBoot];
    return bootTime;
}

- (NSDate*)roundedBootTimeByKernel
{
    NSDate *today = [NSDate date];
    [self uptimeByKernel];
    NSTimeInterval secondsSinceLastBoot = [self secondsSinceBootByKernel] * -1;
    NSDate *bootTime = [today dateByAddingTimeInterval:secondsSinceLastBoot];
    
    NSString *gregorianType = NSGregorianCalendar;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:gregorianType];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:bootTime];
    
    // 7/3/13: Direct retrieval of a boot time doesn't need this, but included as a safety net.
#define SectionMinutes 5
#ifdef DEBUG
    NSInteger seconds = [components second];
#endif
    NSInteger minutes = [components minute];
    NSInteger remainder = minutes % SectionMinutes;
    NSInteger floorMinutes = minutes - remainder;
    
#define USE_FLOOR
#ifdef USE_FLOOR
    [components setMinute:floorMinutes];
    [components setSecond:0];
#else
    [components setMinute:minutes];
    [components setSecond:0];
#endif
    
    NSDate *roundedBootTime = [calendar dateFromComponents:components];
#ifdef DEBUG
    NSLog(@"minutes:%d, seconds:%d, remainder:%d, floorMinutes:%d, last boot secs:%.3f",
          minutes, seconds, remainder, floorMinutes, secondsSinceLastBoot);
    NSString *dateString = [self stringFromMediumTimeFormatter:roundedBootTime];
    NSLog(@"roundedBootDate: %@", dateString);
#endif
    return roundedBootTime;
}

- (NSString*)bootTimeString
{
    NSDate *date = [self roundedBootTimeByKernel];
    NSString *dateString = [self stringFromMediumTimeFormatter:date];
    return dateString;
}

//- (NSDateComponents*)currentDataComponents {
//    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
//    NSDate *today = [NSDate date];
//    NSString *gregorianType = NSGregorianCalendar;
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:gregorianType];
//    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
//    return components;
//}

- (NSInteger)previousMonthOfToday {
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    NSString *gregorianType = NSGregorianCalendar;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:gregorianType];
    
    NSDate *today = [NSDate date];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags
                                               fromDate:today];
    NSDate *currentMonthDate = [calendar dateFromComponents:components];

    
    NSDateComponents *previousComponents = [[NSDateComponents alloc] init];
    previousComponents.month = -1;
    NSDate *previousDate = [calendar dateByAddingComponents:previousComponents
                                                     toDate:currentMonthDate
                                                    options:0];

    components = [calendar components:unitFlags
                             fromDate:previousDate];
    NSInteger month = [components month];
    return month;
}

// Updated Version from Call Minutes Pro v6.0
- (NSDate*)dateFromNextMonthDayIfPassed:(NSInteger)day
{
    NSDateComponents *emptyComponents = [[NSDateComponents alloc] init];
    emptyComponents.year = [MGCurrentBillPeriod yearOfToday];
    emptyComponents.month = [MGCurrentBillPeriod monthOfToday];
    emptyComponents.day = day;
    
    // Need a uniform calendar comparison by using Gregorian calendar everywhere.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentMonthDate = [calendar dateFromComponents:emptyComponents];
    
    NSInteger currentDayInMonth = [MGCurrentBillPeriod dayOfToday];
    if (day > currentDayInMonth) {
        return currentMonthDate;
    }
    
    NSDateComponents *nextMonthComponents = [[NSDateComponents alloc] init];
    nextMonthComponents.month = 1;
    NSDate *nextMonthDate = [calendar dateByAddingComponents:nextMonthComponents
                                                      toDate:currentMonthDate
                                                     options:0];
    return nextMonthDate;
}

- (u_int64_t)receivedWifiInUnit
{
    u_int64_t value = receivedWifiInOctets;
#ifdef DEBUG0
    NSLog(@"%s: value: %llu", __FUNCTION__, value);
#endif
    return value;
}

- (u_int64_t)sentWifiInUnit
{
    u_int64_t value = sentWifiInOctets;
#ifdef DEBUG0
    NSLog(@"%s: value: %llu", __FUNCTION__, value);
#endif
    return value;
}

- (u_int64_t)receivedWANInUnit
{
    u_int64_t value = receivedWanInOctets;
#ifdef DEBUG0
    NSLog(@"%s: value: %llu", __FUNCTION__, value);
#endif
    return value;
}

- (u_int64_t)sentWANInUnit
{
    u_int64_t value = sentWanInOctets;
#ifdef DEBUG0
    NSLog(@"%s: value: %llu", __FUNCTION__, value);
#endif
    return value;
}

- (NSString*)readableUsageIn64Unit:(int64_t)bytes
{
    if (bytes < 0) {
        bytes *= -1;
    }
    if (bytes < 10240) {
        return [NSString stringWithFormat:@"%lld bytes", bytes];
    } else {
        float valueInKB = bytes / 1024.0;
        if (valueInKB < 10240) {
            return [NSString stringWithFormat:@"%.1f KB", valueInKB];
        } else {
            float valueInMB = valueInKB / 1024.0;
            if (valueInMB < 10240) {
                return [NSString stringWithFormat:@"%.1f MB", valueInMB];
            } else {
                float valueInGB = valueInMB / 1024.0;
                return [NSString stringWithFormat:@"%.1f GB", valueInGB];
            }
        }
    }
}

- (NSString*)readableUsageIn32Unit:(u_int32_t)bytes
{
    // 7/2/2013: 10240 gives better readable and comparable precision digits.
    if (bytes < 10240) {
        return [NSString stringWithFormat:@"%d bytes", bytes];
    } else {
        float valueInKB = bytes / 1024.0;
        if (valueInKB < 10240) {
            return [NSString stringWithFormat:@"%.1f KB", valueInKB];
        } else {
            float valueInMB = valueInKB / 1024.0;
            if (valueInMB < 10240) {
                return [NSString stringWithFormat:@"%.1f MB", valueInMB];
            } else {
                float valueInGB = valueInMB / 1024.0;
                return [NSString stringWithFormat:@"%.1f GB", valueInGB];
            }
        }
    }
}

- (void)sampleNetworkInterfaces {
#ifdef DEBUG0
    NSLog(@"%s:", __FUNCTION__);
#endif
    float sentInUnit = 0;
    float receivedInUnit = 0;
    struct ifaddrs *addrs;
    BOOL success = getifaddrs(&addrs) == 0;
    if (success) {
        sentWifiInOctets = 0;
        receivedWifiInOctets = 0;
        sentWanInOctets = 0;
        receivedWanInOctets = 0;
        
        NSString *name = [[NSString alloc] init];
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                const struct if_data *networkStatisc = nil;
                if ([name hasPrefix:@"en"]) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    sentWifiInOctets += networkStatisc->ifi_obytes;
                    receivedWifiInOctets += networkStatisc->ifi_ibytes;
                    sentInUnit = sentWifiInOctets;
                    receivedInUnit = receivedWifiInOctets;
                    if (networkStatisc != nil &&
                        (networkStatisc->ifi_ibytes > 0 || networkStatisc->ifi_obytes > 0)) {
#ifdef DEBUG0
                        NSString *oString = [self readableUsageIn32Unit:networkStatisc->ifi_obytes];
                        NSString *iString = [self readableUsageIn32Unit:networkStatisc->ifi_ibytes];
                        NSLog(@"%@: ifi_obytes: %@, ifi_ibytes: %@", name, oString, iString);
#endif
                    }
                }
                if ([name hasPrefix:@"pdp_ip"]) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    sentWanInOctets += networkStatisc->ifi_obytes;
                    receivedWanInOctets += networkStatisc->ifi_ibytes;
                    sentInUnit = sentWanInOctets;
                    receivedInUnit = receivedWanInOctets;
                    if (networkStatisc != nil &&
                        (networkStatisc->ifi_ibytes > 0 || networkStatisc->ifi_obytes > 0)) {
#ifdef DEBUG
                        NSString *oString = [self readableUsageIn32Unit:networkStatisc->ifi_obytes];
                        NSString *iString = [self readableUsageIn32Unit:networkStatisc->ifi_ibytes];
                        NSLog(@"%@: ifi_obytes: %@, ifi_ibytes: %@", name, oString, iString);
#endif
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
#ifdef DEBUG0
    NSString *sentWanString = [self readableUsageIn64Unit:sentWanInOctets];
    NSString *receivedWanString = [self readableUsageIn64Unit:receivedWanInOctets];
    NSString *bothWanString = [self readableUsageIn64Unit:sentWanInOctets + receivedWanInOctets];
    NSLog(@"wwan: sent: %@, received: %@, both: %@", sentWanString, receivedWanString, bothWanString);
#endif
}

#define BOOT_TIME_SENT_INDEX 0
#define BOOT_TIME_RECEIVED_INDEX 1


- (void)updateBootTimeRecords
{
    NSDate *realBootTime = [self rawBootTimeByKernel];
    NSDate *roundedBootTime = [self roundedBootTimeByKernel];
    NSString *keyString = [self stringFromShortTimeFormatter:roundedBootTime];
#ifdef DEBUG0
    NSLog(@"%s: lastBootDate:%@", __FUNCTION__, keyString);
#endif
    
//#define TEST_WIFI
#ifdef TEST_WIFI
    unsigned long long received = receivedWifiInOctets;
    unsigned long long sent = sentWifiInOctets;
#else
    unsigned long long received = receivedWanInOctets;
    unsigned long long sent = sentWanInOctets;
#endif
    [self loadBootTimeUsages];
    
    NSArray *allValues = self.bootTimes.allValues;
    for (NSArray *array in allValues) {
        NSNumber *sentNumber = [array objectAtIndex:BOOT_TIME_SENT_INDEX];
        NSNumber *receivedNumber = [array objectAtIndex:BOOT_TIME_RECEIVED_INDEX];
        
        unsigned long long sentSaved = [sentNumber unsignedLongLongValue];
        unsigned long long receivedSaved = [receivedNumber unsignedLongLongValue];
        if (sent == sentSaved && received == receivedSaved) {
#ifdef DEBUG
            NSLog(@"duplicate: sent: %llu, received: %llu", sentSaved, receivedSaved);
#endif
            return;
        }
    }
    [self uptimeByKernel];
    NSTimeInterval secondsSinceLastBoot = [self secondsSinceBootByKernel];
    NSNumber *secondsSince = [NSNumber numberWithDouble:secondsSinceLastBoot];
    NSDate *uptimeInDate = [self uptimeInDate];
    NSNumber *receivedNumber = [NSNumber numberWithUnsignedLongLong:received];
    NSNumber *sentNumber = [NSNumber numberWithUnsignedLongLong:sent];
    NSArray *array = @[sentNumber, receivedNumber, realBootTime, secondsSince, uptimeInDate];
    [self.bootTimes setObject:array forKey:keyString];
//#ifdef DEBUG
//        NSLog(@"%s :receivedNumber:%@", __FUNCTION__, receivedNumber);
//#endif
    [self saveBootTimeUsages];
}

// Total Usage for the current usage period.
- (void)addUsagesByBootTimes {
    u_int64_t receivedInt64 = 0;
    u_int64_t sentInt64 = 0;
    MGDataManager *manager = [MGDataManager sharedInstance];
    NSArray *keys = [manager.bootTimes allKeys];
#ifdef DEBUG
    NSLog(@"%s :bootTimes:%@", __FUNCTION__, keys);
#endif
    for (id keyObject in keys) {
        NSArray *array = [manager.bootTimes objectForKey:keyObject];
        NSNumber *sentNumber = [array objectAtIndex:BOOT_TIME_SENT_INDEX];
        NSNumber *receivedNumber = [array objectAtIndex:BOOT_TIME_RECEIVED_INDEX];
        sentInt64 += [sentNumber unsignedLongLongValue];
        receivedInt64 += [receivedNumber unsignedLongLongValue];
    }
    NSNumber *newReceivedInMB = [NSNumber numberWithUnsignedLongLong:receivedInt64];
    NSNumber *newSentInMB = [NSNumber numberWithUnsignedLongLong:sentInt64];
#ifdef DEBUG
    NSString *sentInt64String = [self readableUsageIn64Unit:sentInt64];
    NSString *receivedInt64String = [self readableUsageIn64Unit:receivedInt64];
    NSLog(@"%s: sentInt64String:%@, receivedInt64: %@", __FUNCTION__,
          sentInt64String, receivedInt64String);
#endif
    [self setDataReceivedInMB:newReceivedInMB];
    [self setDataSentInMB:newSentInMB];
}

- (BOOL)isNewUsagePeriod
{
    if (! self.currentBillPeriod) {
        [self loadCurrentBillPeriod];
    }

    BOOL justPassedNewPeriod = NO;
    NSDate *lastAnchoredDate = [self.currentBillPeriod lastAnchoredDateFromBillRecord];
    NSDate *billDateFromThisMonth = [self.currentBillPeriod resetDateOfThisMonth];
    NSDate *today = [NSDate date];

    NSTimeInterval passedSecondsFromThisMonthBillDateToToday = [today timeIntervalSinceDate:billDateFromThisMonth];
    NSTimeInterval passedSecondsFromAnchoredDateToBillDate = [billDateFromThisMonth timeIntervalSinceDate:lastAnchoredDate];
    
    // [This Month Bill Date] <= [Today]
    if (passedSecondsFromThisMonthBillDateToToday >= 0) {
        // [Last Anchored Date] <= [This Month Bill Date]
        if (passedSecondsFromAnchoredDateToBillDate >= 0) {
            justPassedNewPeriod = YES;
        } else {
            // [This Month Bill Date] < [Last Anchored Date]
            justPassedNewPeriod = NO;
        }
    } else {
        //  [Today] < [This Month Bill Date]
        justPassedNewPeriod = NO;
    }

    // 7/5/2013: after having used the old anchor date, save today as the new anchor date.
    [self saveTodayInBillRecord];
    [self saveCurrentBillPeriod];
    return justPassedNewPeriod;
}

- (BOOL)clearAndSaveBootTimeUsageIfNewPeriod
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    [self loadUsedMonths];
    if ([self isNewUsagePeriod]) {
        NSInteger previousMonth = [self previousMonthOfToday];
        NSNumber *monthNumber = [NSNumber numberWithInteger:previousMonth];
        MGDataUsageObject *dataUsage = [self.usedMonths objectForKey:monthNumber];
        if (! dataUsage) {
            dataUsage = [[MGDataUsageObject alloc] init];
        }
        [dataUsage setDataReceivedInMB:self.dataReceivedInMB];
        [dataUsage setDataSentInMB:self.dataSentInMB];
        [self.usedMonths setObject:dataUsage forKey:monthNumber];
        [self clearBootTimeUsages];
        [self saveUsedMonths];
        return YES;
    }
    [self saveUsedMonths];
    return NO;
}

// call increaseAccelerometerFrequency before calling this function.
- (void)sampleUsageAndUpdateRecords
{
    [self sampleNetworkInterfaces];
    [self updateBootTimeRecords];
    [self addUsagesByBootTimes];
}

//- (void)increaseAccelerometerFrequency {
//    // speed up the accelerometer sampling rate,
//    // so the sample timestamp is up to date, when timestamp is used.
//    NSTimeInterval updateInterval = 1/5.0;
//    [_motionManager setAccelerometerUpdateInterval:updateInterval];
//}

- (CGFloat)usedDataInPercentile
{
    NSNumber *number = [self.currentBillPeriod dataQuotaInMB];
    NSUInteger dataQuotaInMB = [number unsignedIntegerValue];
    float dataQuotaFloat = dataQuotaInMB;
    
    float usage = [self adjustedCurrentDataUsageInFloat];
    CGFloat percentile = usage / dataQuotaFloat * 100.0;
    return percentile;
}

- (float)nonAdjustedCurrentDataUsageInFloat
{
    float usedDataInUnit = 0;
    NSNumber *receivedNumber = [self dataReceivedInMB];
    NSNumber *sentNumber = [self dataSentInMB];
    if (receivedNumber && sentNumber) {
        u_int64_t oldReceivedInt64 = [receivedNumber unsignedLongLongValue];
        u_int64_t oldSentInt64 = [sentNumber unsignedLongLongValue];
        u_int64_t sum = oldReceivedInt64 + oldSentInt64;
        u_int64_t sigmaInt64 = sum;
#ifdef DEBUG
        NSString *sigmaString = [self readableUsageIn64Unit:sigmaInt64];
        NSLog(@"%s: sigmaInt64: %@", __FUNCTION__, sigmaString);
#endif
        
        const float BytesPerMB = 1024 * 1024.0;
        usedDataInUnit = sigmaInt64 / BytesPerMB;
        return usedDataInUnit;
    } else {
        return usedDataInUnit;
    }
}

- (float)adjustedCurrentDataUsageInFloat
{
    int64_t sigmaInt64 = 0;
    const float BytesPerMB = 1024 * 1024.0;
    
    if (self.currentBillPeriod) {
        NSNumber *adjustedDataUsage = [self.currentBillPeriod adjustedDataUsageInMB];
        if (adjustedDataUsage) {
            // 7/17/13: Adjusted usage value can be negative.
            float adjustedInUnit = [adjustedDataUsage floatValue];
            double adjustedInBytes = adjustedInUnit * BytesPerMB;
            int64_t adjustedInt64 = adjustedInBytes;
            sigmaInt64 += adjustedInt64;
#ifdef DEBUG
            NSString *adjustedInt64String = [self readableUsageIn64Unit:adjustedInt64];
            NSLog(@"%s: adjustedInt64: %@", __FUNCTION__, adjustedInt64String);
#endif
        }
    }
    
    float usedDataInUnit = 0;
    NSNumber *receivedNumber = [self dataReceivedInMB];
    NSNumber *sentNumber = [self dataSentInMB];
    if (receivedNumber && sentNumber) {
        u_int64_t oldReceivedInt64 = [receivedNumber unsignedLongLongValue];
        u_int64_t oldSentInt64 = [sentNumber unsignedLongLongValue];
        u_int64_t sigma = oldReceivedInt64 + oldSentInt64;
        sigmaInt64 += sigma;
#ifdef DEBUG0
        NSString *sigmaInt64String = [self readableUsageIn64Unit:sigmaInt64];
        NSString *sigmaString = [self readableUsageIn64Unit:sigma];
        NSLog(@"%s: sigmaInt64: %@, sigma: %@", __FUNCTION__, sigmaInt64String, sigmaString);
#endif
        usedDataInUnit = sigmaInt64 / BytesPerMB;
        return usedDataInUnit;
    } else {
        return usedDataInUnit;
    }
}

- (NSString*)currentPeriodUsageStringWith:(float)usedDataInUnit
{
//#ifdef DEBUG
//    NSLog(@"%s: usedDataInUnit:%lf", __FUNCTION__, usedDataInUnit);
//#endif
    NSString *string = nil;
    if (usedDataInUnit == 0) {
        string = [NSString stringWithFormat:@"Zero"];
        return string;
    }
    if (usedDataInUnit < 0.01) {
        string = [NSString stringWithFormat:@"%.4f", usedDataInUnit];
        return string;
    }
    if (usedDataInUnit < 0.1) {
        string = [NSString stringWithFormat:@"%.3f", usedDataInUnit];
        return string;
    }
    if (usedDataInUnit < 1) {
        string = [NSString stringWithFormat:@"%.2f", usedDataInUnit];
        return string;
    }
    if (usedDataInUnit < 10) {
        string = [NSString stringWithFormat:@"%.1f", usedDataInUnit];
        return string;
    }
    if (usedDataInUnit < 100) {
        string = [NSString stringWithFormat:@"%.1f", usedDataInUnit];
        return string;
    }
    if (usedDataInUnit < 1000) {
        string = [NSString stringWithFormat:@"%.0f", usedDataInUnit];
    } else {
        string = [NSString stringWithFormat:@"%.0f", usedDataInUnit];
    }
    return string;
}

- (NSString*)maskStringForDataUsage:(float)usedDataInUnit
{
    NSString *string = nil;
    if (usedDataInUnit == 0) {
        string = [NSString stringWithFormat:@"88888"];
        return string;
    }
    if (usedDataInUnit < 0.01) {
        string = [NSString stringWithFormat:@"88.8888"];
        return string;
    }
    if (usedDataInUnit < 0.1) {
        string = [NSString stringWithFormat:@"888.888"];
        return string;
    }
    if (usedDataInUnit < 1) {
        string = [NSString stringWithFormat:@"8888.88"];
        return string;
    }
    if (usedDataInUnit < 10) {
        string = [NSString stringWithFormat:@"88888.8"];
        return string;
    }
    if (usedDataInUnit < 100) {
        string = [NSString stringWithFormat:@"88888.8"];
        return string;
    }
    if (usedDataInUnit < 1000) {
        string = [NSString stringWithFormat:@"88888"];
    } else {
        string = [NSString stringWithFormat:@"88888"];
    }
    return string;
}

- (NSString*)maskStringForDataUsage
{
    float usedDataInUnit = [self adjustedCurrentDataUsageInFloat];
    NSString *string = [self maskStringForDataUsage:usedDataInUnit];
    return string;
#ifdef DEBUG
    NSLog(@"%s: mask:%@", __FUNCTION__, string);
#endif
}

- (NSString*)currentPeriodUsageString
{
    float usedDataInUnit = [self adjustedCurrentDataUsageInFloat];
    NSString *string = [self currentPeriodUsageStringWith:usedDataInUnit];
    return string;
}

#define DefaultResetDay 15
#define DefaultDataQuotaInMB 2048

- (void)instantiateCurrentBillPeriod:(NSUInteger)day
{
    MGCurrentBillPeriod *billPeriod = [[MGCurrentBillPeriod alloc] init];
    [self setCurrentBillPeriod:billPeriod];
    
    NSNumber *dayOfMonth = [NSNumber numberWithUnsignedInteger:day];
    [billPeriod setBillDayOfMonth:dayOfMonth];
    
    NSUInteger quotaInMB = DefaultDataQuotaInMB;
    NSNumber *number = [NSNumber numberWithUnsignedInteger:quotaInMB];
    [billPeriod setDataQuotaInMB:number];
}

- (void)instantiateCurrentBillPeriod
{
    [self instantiateCurrentBillPeriod:DefaultResetDay];
}

- (void)saveTodayInBillRecord
{
    NSDate *today = [NSDate date];
    MGCurrentBillPeriod *billPeriod = self.currentBillPeriod;
    [billPeriod setLastAnchoredDate:today];
}

#define CurrentBillPeriodKey @"currentBillPeriod"

- (void)loadCurrentBillPeriod
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:CurrentBillPeriodKey];
    if (data) {
        MGCurrentBillPeriod *unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self setCurrentBillPeriod:unarchived];
    } else {
        [self instantiateCurrentBillPeriod:DefaultResetDay];
        [self saveTodayInBillRecord];
    }
}

- (void)saveCurrentBillPeriod
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentBillPeriod];
    [defaults setObject:data forKey:CurrentBillPeriodKey];
    BOOL saved = [[NSUserDefaults standardUserDefaults] synchronize];
    if (0) {
        NSLog(@"%s: saved:%d", __func__, saved);
    }
}

- (void)updateDataQuotaInMB:(NSUInteger)quotaInMB
{
    if (! self.currentBillPeriod) {
        [self instantiateCurrentBillPeriod:DefaultResetDay];
    } else {
        NSNumber *number = [NSNumber numberWithUnsignedInteger:quotaInMB];
        [self.currentBillPeriod setDataQuotaInMB:number];
    }
}

- (void)updateCurrentBillPeriod:(NSUInteger)resetDay
{
    if (! self.currentBillPeriod) {
        [self instantiateCurrentBillPeriod:resetDay];
    } else {
        NSNumber *dayOfMonth = [NSNumber numberWithUnsignedInteger:resetDay];
        [self.currentBillPeriod setBillDayOfMonth:dayOfMonth];
    }
}

- (void)updateCurrentBillPeriodWithAdjustedDataUsage:(float)usedDataInMB
{
    if (! self.currentBillPeriod) {
        [self instantiateCurrentBillPeriod:DefaultResetDay];
    } else {
        NSNumber *number = [NSNumber numberWithFloat:usedDataInMB];
        [self.currentBillPeriod setAdjustedDataUsageInMB:number];
    }
}

#define UsedMonthPropertyKey @"usedmonths"

- (void)loadUsedMonths {
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:UsedMonthPropertyKey];
    if (data) {
        NSDictionary *unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableDictionary *mutable = [unarchived mutableCopy];
        [self setUsedMonths:mutable];
    } else {
        NSUInteger months = 12;
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:months];
        [self setUsedMonths:dictionary];
    }
}

- (void)saveUsedMonths {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.usedMonths];
    [defaults setObject:data forKey:UsedMonthPropertyKey];
    BOOL saved = [[NSUserDefaults standardUserDefaults] synchronize];
#ifdef DEBUG
    NSLog(@"%s: saved:%d", __func__, saved);
#else
    NSLog(@"%s: saved:%d", __func__, saved);
#endif
}

#define PropertyList_Filename @"bootTimes.plist"
- (void)saveBootTimeUsages{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:PropertyList_Filename];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.bootTimes
                                                                   format:NSPropertyListBinaryFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        BOOL succeeded = [plistData writeToFile:plistPath atomically:YES];
        if (! succeeded) {
            NSLog(@"%s: %@", __FUNCTION__, error);
        }
    } else {
        NSLog(@"%@",error);
    }
}

- (void)loadBootTimeUsages {
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:PropertyList_Filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *retrieved = (NSDictionary *)[NSPropertyListSerialization
                                                   propertyListFromData:plistXML
                                                   mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                   format:&format
                                                   errorDescription:&errorDesc];
        if (retrieved) {
            [self.bootTimes removeAllObjects];
            [self.bootTimes addEntriesFromDictionary:retrieved];
        } else {
            NSLog(@"%s: Error reading plist: errorDesc: %@", __FUNCTION__, errorDesc);
        }
    } else {
        NSLog(@"%s: Error: data usage plist not found", __FUNCTION__);
    }
}

- (void)clearBootTimeUsages {
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    [self.bootTimes removeAllObjects];
    [self saveBootTimeUsages];
}

@end
