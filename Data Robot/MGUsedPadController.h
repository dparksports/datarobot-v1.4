//
//  MGDayPadController.h
//  ROBO
//
//  Created by Dan Park on 6/22/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol MGUsedDataPadProtocol;
@interface MGUsedPadController : UIViewController
@property (nonatomic, assign, readonly) float dataUsedInUnit;
@property (nonatomic, assign) NSObject<MGUsedDataPadProtocol> *delegate;
- (void)updateValue:(NSUInteger)value;
@end

@protocol MGUsedDataPadProtocol
@optional
- (void)updateUsedData:(float)dataUsedInUnit;
@end