//
//  MGDataUsageObject.m
//  Data Robot
//
//  Created by Dan Park on 6/6/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGDataUsageObject.h"

@implementation MGDataUsageObject

#define SENT_DATA_NAME @"sent"
#define RECEIVED_DATA_NAME @"received"

- (id) initWithCoder: (NSCoder *)coder {
    self = [self init];
    if (self != nil) {
        self.dataSentInMB = [coder decodeObjectForKey: SENT_DATA_NAME];
        self.dataReceivedInMB = [coder decodeObjectForKey: RECEIVED_DATA_NAME];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject: _dataSentInMB forKey: SENT_DATA_NAME];
    [coder encodeObject: _dataReceivedInMB forKey: RECEIVED_DATA_NAME];
}

@end
