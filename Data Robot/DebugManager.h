//
//  DebugManager.h
//  S8
//
//  Created by Dan Park on 7/22/11.
//  Copyright 2011 www.magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DebugManager : NSObject

+ (void)printMinutesUsedStartEndTimes:(NSString*)functionName start:(NSTimeInterval)callStart end:(NSTimeInterval)callEnd usage:(NSInteger)usedSeconds;
@end
