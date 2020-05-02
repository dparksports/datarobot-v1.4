//
//  CallEvent.h
//  S3
//
//  Created by Dan Park on 6/4/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallEvent : NSObject
{
    NSString *callID;
    NSTimeInterval dialingTime;
    NSTimeInterval incomingTime;
    NSTimeInterval connectedTime;
    NSTimeInterval disconnectedTime;
}
@property (nonatomic, copy) NSString *callID; 
@property (nonatomic, assign) NSTimeInterval dialingTime; 
@property (nonatomic, assign) NSTimeInterval incomingTime; 
@property (nonatomic, assign) NSTimeInterval connectedTime; 
@property (nonatomic, assign) NSTimeInterval disconnectedTime; 

+ (CallEvent*)instanceDialing:(NSString*)callID time:(NSTimeInterval)time;
+ (CallEvent*)instanceIncoming:(NSString*)callID time:(NSTimeInterval)time;
+ (CallEvent*)instanceConnectedTime:(NSString*)callID time:(NSTimeInterval)time;
+ (CallEvent*)instanceDisconnectedTime:(NSString*)callID time:(NSTimeInterval)time;

- (NSTimeInterval)eventTime;
- (BOOL)isIncomingCall;

@end
