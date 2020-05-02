//
//  NotificationManager.h
//  DetectRegion
//
//  Created by Dan Park on 7/13/11.
//  Copyright 2011 MAGIC POINT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *NotificationManagerUpdate;

@interface NotificationManager : NSObject
{
    NSOperationQueue *serialQueue;
    NSMutableArray *events;
}
@property (nonatomic, retain) NSOperationQueue *serialQueue;
@property (nonatomic, retain) NSMutableArray *events;

+ (NotificationManager *)sharedInstance;
- (void)addTimestampedEvent:(NSString*)eventName;
- (void)addKeyObjectEvent:(id)key object:(id)object;

- (void)saveEmptyProperyList;
- (void)saveProperyList;
- (void)loadProperyList;
- (void)unloadEvents;


@end
