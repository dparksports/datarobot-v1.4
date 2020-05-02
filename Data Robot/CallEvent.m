//
//  CallEvent.m
//  S3
//
//  Created by Dan Park on 6/4/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "CallEvent.h"

@implementation CallEvent
@synthesize callID;
@synthesize dialingTime, incomingTime, connectedTime, disconnectedTime;

+ (CallEvent*)instanceDialing:(NSString*)callID time:(NSTimeInterval)time
{
    CallEvent *event = [[CallEvent alloc] init];
    event.callID = callID;
    event.dialingTime = time;
    
    return event;
}

+ (CallEvent*)instanceIncoming:(NSString*)callID time:(NSTimeInterval)time
{
    CallEvent *event = [[CallEvent alloc] init];
    event.callID = callID;
    event.incomingTime = time;
    
    return event;
}

+ (CallEvent*)instanceConnectedTime:(NSString*)callID time:(NSTimeInterval)time
{
    CallEvent *event = [[CallEvent alloc] init];
    event.callID = callID;
    event.connectedTime = time;
    
    return event;
}

+ (CallEvent*)instanceDisconnectedTime:(NSString*)callID time:(NSTimeInterval)time
{
    CallEvent *event = [[CallEvent alloc] init];
    event.callID = callID;
    event.disconnectedTime = time;
    
    return event;
}

- (BOOL)isIncomingCall
{
    return incomingTime > 0;
}


- (NSTimeInterval)eventTime
{
    return connectedTime;
    
//    if (connectedTime > 0) {
//        return connectedTime;
//    } 
//    
//    if (dialingTime > 0) {
//        return dialingTime;
//    } 
//    
//    if (incomingTime > 0) {
//        return incomingTime;
//    } 
//    
//    if (disconnectedTime > 0) {
//        return disconnectedTime;
//    }
//    
//    return [NSDate timeIntervalSinceReferenceDate];
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        incomingTime = 0;
        dialingTime = 0;
        connectedTime = 0;
        disconnectedTime = 0;
    }
    
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@:%lf", callID, [self eventTime]];
}

@end
