//
//  MGDayPadController.h
//  ROBO
//
//  Created by Dan Park on 6/22/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol MGDayPadProtocol;
@interface MGDayPadController : UIViewController
@property (nonatomic, assign, readonly) NSUInteger timeInSeconds;
@property (nonatomic, assign) NSUInteger updatedScore;
@property (nonatomic, assign) NSObject<MGDayPadProtocol> *delegate;
- (void)updateValue:(NSUInteger)value;
@end

@protocol MGDayPadProtocol
- (void)updateResetDay:(NSUInteger)day;
@end