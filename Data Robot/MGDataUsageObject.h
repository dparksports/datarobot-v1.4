//
//  MGDataUsageObject.h
//  Data Robot
//
//  Created by Dan Park on 6/6/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGDataUsageObject : NSObject
@property (nonatomic, strong) NSNumber *dataReceivedInMB;
@property (nonatomic, strong) NSNumber *dataSentInMB;
@end
