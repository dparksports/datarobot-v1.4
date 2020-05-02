//
//  NotificationManager.m
//  DetectRegion
//
//  Created by Dan Park on 7/13/11.
//  Copyright 2011 MAGIC POINT. All rights reserved.
//

#import "NotificationManager.h"

NSString *NotificationManagerUpdate = @"NotificationManagerUpdate";	 

@implementation NotificationManager
@synthesize serialQueue, events;

// 10/4 : decreased count to 5 for Release 
//#define MaxEvents 50
#define MaxEvents 5

+ (NSString*)formatTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterLongStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

+ (NSString*)backgroundTimeRemaining
{
    NSTimeInterval maxInterval = [UIApplication sharedApplication].backgroundTimeRemaining;
    NSString *maxString =  (maxInterval >= MAXFLOAT) 
    ? @"max bgtr" 
    : [NSString stringWithFormat:@"%lf", maxInterval];
    
    NSString *formatedStatus = [NSString stringWithFormat:@"%@ %@", 
                                [self.class formatTimestamp:[NSDate date]], maxString];    
    return formatedStatus;
}

- (void)notifyUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationManagerUpdate 
                                                        object:self 
                                                      userInfo:nil];
}

- (void)addEvent:(NSDictionary*)eventInfo
{
    [events insertObject:eventInfo atIndex:0];
    while ([events count] > MaxEvents) {
        [events removeLastObject];
    }
    
    [self notifyUpdate];    
}

- (void)addKeyObjectEvent:(id)key object:(id)object
{
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               [key description], [object description],
                               nil];
    
    [self addEvent:eventInfo];
}

- (void)addTimestampedEvent:(NSString*)eventName
{
    NSDate *date = [NSDate date];    
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self.class formatTimestamp:date], eventName,
                               nil];

    [self addEvent:eventInfo];
}

//- (void)registerDidBecomeActiveNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         // 6/22 : systemTimeZone per app may have changed since app resigned active.
//         //      : resetting it here per CalendarComponents
//         [NSTimeZone resetSystemTimeZone];
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [self.class backgroundTimeRemaining], @"DidBecomeActiveNotification",
//                                    nil];
//         
//         [self addEvent:eventInfo];
//     }
//     ];
//}

//- (void)registerWillEnterForegroundNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0 && 0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [self.class backgroundTimeRemaining], @"WillEnterForegroundNotification",
//                                    nil];
//         
//         [self addEvent:eventInfo];
//     }
//     ];
//}


- (void)registerDidEnterBackgroundNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self.class backgroundTimeRemaining], @"DidEnterBackgroundNotification",
                                    nil];
         [self addEvent:eventInfo];
         [self saveProperyList];
     }
     ];
}


- (void)registerWillTerminateNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self.class backgroundTimeRemaining], @"WillTerminateNotification",
                                    nil];
         
         [self addEvent:eventInfo];
         [self saveProperyList];
     }
     ];
}

//- (void)registerWillResignActiveNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [self.class backgroundTimeRemaining], @"WillResignActiveNotification",
//                                    nil];
//         [self addEvent:eventInfo];
//         [self saveProperyList];
//     }
//     ];
//}

- (void)registerSignificantTimeChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationSignificantTimeChangeNotification
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self.class backgroundTimeRemaining], @"SignificantTimeChangeNotification",
                                    nil];
         [self addEvent:eventInfo];
     }
     ];
}


- (void)registerDidReceiveMemoryWarningNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                      object:nil 
                                                       queue:serialQueue
                                                  usingBlock:^(NSNotification *notif) 
     {
         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self.class backgroundTimeRemaining], @"DidReceiveMemoryWarningNotification",
                                    nil];
         if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) 
         {
             [self unloadEvents];
         } 
         [self addEvent:eventInfo];
         [self saveProperyList];
     }
     ];
}

//- (void)registerDidFinishLaunchingNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
//                                                      object:nil 
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif) 
//     {
//         if (0) {
//             NSLog(@"%s", __FUNCTION__);
//         }
//         
//         
//         NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [self.class backgroundTimeRemaining], @"DidFinishLaunchingNotification",
//                                    nil];
//         [self addEvent:eventInfo];
//     }
//     ];
//}

- (void)registerNotifications {
    self.serialQueue = [[NSOperationQueue alloc] init];
    [serialQueue setMaxConcurrentOperationCount:1];

//    [self registerDidFinishLaunchingNotification];
    
//    [self registerWillResignActiveNotification];
//    [self registerDidBecomeActiveNotification];
    
//    [self registerWillEnterForegroundNotification];
    [self registerDidEnterBackgroundNotification];
    
    [self registerWillTerminateNotification];
    
    [self registerSignificantTimeChangeNotification];
    [self registerDidReceiveMemoryWarningNotification];
    
    
    
}

- (void)saveEventsOnly {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"events.plist"];
    
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

- (void)saveEmptyProperyList
{
    [events removeAllObjects];
    [self saveEventsOnly];
    [self addTimestampedEvent:@"saveEmptyProperyList"];
}

- (void)saveProperyList
{
    [self saveEventsOnly];
    [self addTimestampedEvent:@"saveProperyList"];
}


- (void)loadProperyList
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"events.plist"];
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
        
        NSString *message = [NSString stringWithFormat:@"loadProperyList:format:%d",format];
        [self addTimestampedEvent:message];
    } 
    else {
        [self addTimestampedEvent:@"save events not found"];
    }
}

- (void)unloadEvents
{
    [events removeAllObjects];
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        if (!events) {
            self.events = [NSMutableArray arrayWithCapacity:MaxEvents];
        }
    }
    return self;
}

static NotificationManager *singleton = nil;

+ (NotificationManager *)sharedInstance 
{
    if (!singleton) 
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          singleton = [[[self class] alloc] init];
                          [singleton registerNotifications];
                      });
    }
    return singleton;
}
@end
