//
//  MGDayPadController.h
//  ROBO
//
//  Created by Dan Park on 6/22/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol MGQuotaPadProtocol;
@interface MGQuotaPadController : UIViewController
@property (nonatomic, assign, readonly) NSUInteger timeInSeconds;
@property (nonatomic, assign) NSUInteger updatedQuotaInMB;
@property (nonatomic, assign) NSObject<MGQuotaPadProtocol> *delegate;
- (void)updateValue:(NSUInteger)value;
@end

@protocol MGQuotaPadProtocol
- (void)updateDataQuota:(NSUInteger)quotaInMB;
@end
