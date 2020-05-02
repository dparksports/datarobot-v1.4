//
//  CallHistory.m
//  S8
//
//  Created by Dan Park on 7/21/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "HistoryManager.h"
#import "LocationManager.h"

NSString *HMCallPeriod = @"CallPeriodHM";	 
NSString *HMCallStart = @"CallStartHM";	 
NSString *HMCallEnd = @"CallEndHM";	 
NSString *HMCallSeconds = @"CallSecondsHM";	 
NSString *HMCallLat = @"CallLatHM";	 
NSString *HMCallLong = @"CallLongHM";	 

@implementation HistoryManager
@synthesize events;

#define MaxEvents 25

- (id)init
{
    self = [super init];
    if (self) {
        if (!events) {
            self.events = [NSMutableArray arrayWithCapacity:MaxEvents];
        }
    }
    return self;
}

- (void)updateCoordinate:(CLLocationCoordinate2D) newCoordinate
{
    coordinate = newCoordinate;
    updatedCoordinate = YES;
}

- (void)addEvent:(NSDictionary*)eventInfo {
    [events insertObject:eventInfo atIndex:0];
}

- (void)addCallEvent:(NSString*)callPeriod callStart:(NSTimeInterval)startTime callEnd:(NSTimeInterval)endTime duration:(NSInteger)usedSeconds {
    NSDictionary *eventInfo;
    CLLocationDegrees latitude = 0;
    CLLocationDegrees longitude = 0;
    
    // 8/24 : if not passed by breadcrumb vc, use locationmanager.
//    if (updatedCoordinate && CLLocationCoordinate2DIsValid(coordinate)) 
    if (updatedCoordinate) 
    {
        latitude = coordinate.latitude;
        longitude = coordinate.longitude;
        updatedCoordinate = NO;
    } 
    else 
    {
        LocationManager *manager = [LocationManager sharedInstance];
//        [manager notifyLocally:@"no map view available."];
        
        CLLocation *location;
        location = manager.locationManager.location;
        if (! location) {
            location = manager.lastUpdatedLocation;
        }
        
        if (location) 
        {
            CLLocationCoordinate2D locationCoordinate = location.coordinate;
            latitude = locationCoordinate.latitude;
            longitude = locationCoordinate.longitude;
        } 
        else 
        {
            [manager notifyLocally:@"no location found."];
        }
    }
                               
    if (latitude != 0 && longitude != 0)
    {
        
        eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     callPeriod, HMCallPeriod,
                     [NSNumber numberWithDouble:startTime], HMCallStart,
                     [NSNumber numberWithDouble:endTime], HMCallEnd,
                     [NSNumber numberWithInteger:usedSeconds], HMCallSeconds,
                     [NSNumber numberWithDouble:latitude], HMCallLat,
                     [NSNumber numberWithDouble:longitude], HMCallLong,
                     nil];
    } 
    else 
    {
        eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     callPeriod, HMCallPeriod,
                     [NSNumber numberWithDouble:startTime], HMCallStart,
                     [NSNumber numberWithDouble:endTime], HMCallEnd,
                     [NSNumber numberWithInteger:usedSeconds], HMCallSeconds,
                     nil];
    }
    

    [events insertObject:eventInfo atIndex:0];
}

- (void)saveEventsOnly {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"history.plist"];
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:events
                                                                   format:NSPropertyListBinaryFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        BOOL succeeded = [plistData writeToFile:plistPath atomically:YES];
        if (! succeeded) {
            NSLog(@"%s:%@", __FUNCTION__, error);
        }
    }
    else {
        NSLog(@"%@",error);
    }
}

- (void)saveEmptyProperyList {
    [events removeAllObjects];
    [self saveEventsOnly];
}

- (void)saveProperyList {
    [self saveEventsOnly];
}


- (void)loadProperyList {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"history.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) 
    {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSArray *loadedArray = (NSArray *)[NSPropertyListSerialization
                                           propertyListFromData:plistXML
                                           mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                           format:&format
                                           errorDescription:&errorDesc];
        
        [events removeAllObjects];
        [events addObjectsFromArray:loadedArray];
        if (!loadedArray) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
    } 
    else 
    {
        if (0) {
            NSLog(@"%s:Not found: Saved events property list file.", __FUNCTION__);
        }
    }
}

- (void)unloadEvents
{
    [events removeAllObjects];
}

static HistoryManager *singleton = nil;

+ (HistoryManager *)sharedInstance 
{
    if (!singleton) 
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          if (0) {
                              NSLog(@"%s:instantion", __FUNCTION__);
                          }
                          singleton = [[[self class] alloc] init];
                      });
    }
    return singleton;
}

@end
