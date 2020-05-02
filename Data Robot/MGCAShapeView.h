//
//  MGCAShapeView.h
//  Data Robot
//
//  Created by Dan Park on 6/22/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MGCAShapeView : UIView
- (void)createContentLayer;
- (void)loadImageLayer;
- (void)applyPieMaskByPercentile:(CGFloat)percentile;
- (void)animatePieMaskByPercentile:(CGFloat)percentile;
- (void)undoPieMask;
@end
