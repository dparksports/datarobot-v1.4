//
//  DebugManager.m
//  S8
//
//  Created by Dan Park on 7/22/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import "DebugManager.h"

#import "Formats.h"
#import "CalendarComponents.h"

@implementation DebugManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (void)printMinutesUsedStartEndTimes:(NSString*)functionName start:(NSTimeInterval)callStart end:(NSTimeInterval)callEnd usage:(NSInteger)usedSeconds
{
    if (0) {
        NSString *startTimeString = [CalendarComponents dateStringFromInterval:callStart];
        NSString *endTimeString = [CalendarComponents dateStringFromInterval:callEnd];
        
        NSLog(@"%@:startTime:%@, endTime:%@, usedMinutes:%d", functionName, 
              startTimeString, endTimeString, [Formats minutesUsed:usedSeconds]);
    }
}
@end
