//
//  MGCAShapeView.m
//  Data Robot
//
//  Created by Dan Park on 6/22/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGCAShapeView.h"

static inline double radians(double degrees) { return degrees * M_PI / 180; }

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGFloat comps[] = {w, a};
    CGColorRef color = CGColorCreate(gray, comps);
    CGColorSpaceRelease(gray);
    return color;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {r, g, b, a};
    CGColorRef color = CGColorCreate(rgb, comps);
    CGColorSpaceRelease(rgb);
    return color;
}

CGColorRef graphBackgroundColor()
{
    static CGColorRef c = NULL;
    if (c == NULL) {
        c = CreateDeviceGrayColor(0.6, 1.0);
    }
    return c;
}

CGColorRef redColor()
{
    static CGColorRef c = NULL;
    if (c == NULL)
    {
        c = CreateDeviceRGBColor(1.0, 0.0, 0.0, 1.0);
    }
    return c;
}

@interface MGCAShapeView () {
    CGFloat maskPercentile;
}
@property(nonatomic, strong) CAShapeLayer *maskLayer;
@property(nonatomic, strong) CALayer *contentLayer;
@end

@implementation MGCAShapeView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)createContentLayer
{
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    if (! self.contentLayer) {
        CGRect bounds = self.layer.bounds;
        CALayer *layer = [CALayer layer];
//        [layer setDelegate:self];
        [layer setFrame:bounds];
        [self setContentLayer:layer];
        [self.layer addSublayer:self.contentLayer];
//        [self.layer setDelegate:self];
    }
    
    CGRect bounds = self.layer.bounds;
    if (! self.maskLayer) {
        CAShapeLayer *layer = (CAShapeLayer*) [CAShapeLayer layer];
        layer.delegate = self;
        [layer setFrame:bounds];
        [self setMaskLayer:layer];
        [self.contentLayer setMask:self.maskLayer];
        
        const CGAffineTransform m = CGAffineTransformMakeRotation(M_PI / -2.0);
        [self.maskLayer setAffineTransform:m];
    }
}

- (void)loadImageLayer
{
    //#define USE_RED
#ifdef USE_RED
    UIImage *image = [UIImage imageNamed:@"percent_view_show_red.png"];
#else
    UIImage *image = [UIImage imageNamed:@"percent_view_show_green.png"];
#endif
    CGImageRef imageRef = [image CGImage];
    [self.contentLayer setContents:(__bridge id) imageRef];
}

- (void)applyPieMaskByPercentile:(CGFloat)percentile
{
#ifdef DEBUG0
    NSLog(@"%s: percentile:%f", __FUNCTION__, percentile);
#endif
    maskPercentile = percentile;
    
#ifdef DEBUG0
    NSLog(@"%s: self.layer.bounds:%@", __FUNCTION__, NSStringFromCGRect(self.layer.bounds));
#endif
    
//#define USE_LAYER_DELEGATE
#ifdef USE_LAYER_DELEGATE
    [self.maskLayer setNeedsDisplay];
#else
    CGFloat fullCirle = M_PI * 2.0;
    CGFloat startAngle = 0.0;
    CGFloat endAngle = fullCirle * maskPercentile;
    
    CGPoint center;
    CGRect bounds = self.layer.bounds;
	center.x = bounds.size.width/2.0;
	center.y = bounds.size.height/2.0;
	float radius = bounds.size.width/2.0;
    //	float centerSize = radius * 3.5 / 10.0 ;
    
    UIBezierPath *endPath;
	endPath = [[UIBezierPath alloc] init];
	[endPath addArcWithCenter:center
                       radius:radius
                   startAngle:startAngle
                     endAngle:endAngle
                    clockwise:YES];
    [endPath addLineToPoint:center];
	[endPath closePath];
    
    CGPathRef pathRef = [endPath CGPath];
    [self.maskLayer setPath:pathRef];
#endif
    
    
//#define DEBUG_MASK
#ifdef DEBUG_MASK
    [self.layer addSublayer:self.maskLayer];
#endif
}

- (void)animatePieMaskByPercentile:(CGFloat)percentile
{
#ifdef DEBUG
    NSLog(@"%s: percentile:%f", __FUNCTION__, percentile);
#endif
    maskPercentile = percentile;
    
#ifdef DEBUG0
    NSLog(@"%s: self.layer.bounds:%@", __FUNCTION__, NSStringFromCGRect(self.layer.bounds));
#endif
    
    //#define USE_LAYER_DELEGATE
#ifdef USE_LAYER_DELEGATE
    [self.maskLayer setNeedsDisplay];
#else
    CGFloat fullCirle = M_PI * 2.0;
    CGFloat startAngle = 0.0;
    CGFloat endAngle = fullCirle * maskPercentile;
    
    CGPoint center;
    CGRect bounds = self.layer.bounds;
	center.x = bounds.size.width/2.0;
	center.y = bounds.size.height/2.0;
	float radius = bounds.size.width/2.0;
    //	float centerSize = radius * 3.5 / 10.0 ;
    
    UIBezierPath *endPath;
	endPath = [[UIBezierPath alloc] init];
	[endPath addArcWithCenter:center
                       radius:radius
                   startAngle:startAngle
                     endAngle:endAngle
                    clockwise:YES];
    [endPath addLineToPoint:center];
	[endPath closePath];
    
    CGPathRef pathRef = [endPath CGPath];
    [self.maskLayer setPath:pathRef];
    [self startHalfCircleAnimation];
#endif
    
    
    //#define DEBUG_MASK
#ifdef DEBUG_MASK
    [self.layer addSublayer:self.maskLayer];
#endif
}

- (void)startHalfCircleAnimation
{
#ifdef DEBUG0
    NSLog(@"%s", __FUNCTION__);
#endif
    CFTimeInterval duration = 1.0;
	CABasicAnimation *halfCircleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	halfCircleAnimation.removedOnCompletion = NO;
	halfCircleAnimation.duration = duration;
	[halfCircleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	halfCircleAnimation.delegate = self;
//    [halfCircleAnimation setRepeatCount:HUGE_VALF];
    CATransform3D fromTransform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    CATransform3D toTransform = CATransform3DMakeRotation(M_PI / -2.0, 0, 0, 1);
    NSValue *fromValue = [NSValue valueWithCATransform3D:fromTransform];
    NSValue *toValue = [NSValue valueWithCATransform3D:toTransform];
	[halfCircleAnimation setFromValue:fromValue];
	[halfCircleAnimation setToValue:toValue];
	[self.maskLayer addAnimation:halfCircleAnimation forKey:@"halfCircleAnimation"];
}

- (void)lastHalfCircleAnimation
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    CFTimeInterval duration = 0.5;
	CABasicAnimation *lastHalfCircleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	[lastHalfCircleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	lastHalfCircleAnimation.removedOnCompletion = NO;
	lastHalfCircleAnimation.duration = duration;
	lastHalfCircleAnimation.delegate = self;
//    [lastHalfCircleAnimation setRepeatCount:HUGE_VALF];
    CATransform3D fromTransform = CATransform3DMakeRotation(M_PI / -2.0, 0, 0, 1);
    CATransform3D toTransform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    NSValue *fromValue = [NSValue valueWithCATransform3D:fromTransform];
    NSValue *toValue = [NSValue valueWithCATransform3D:toTransform];
	[lastHalfCircleAnimation setFromValue:fromValue];
	[lastHalfCircleAnimation setToValue:toValue];
	[self.maskLayer addAnimation:lastHalfCircleAnimation forKey:@"lastHalfCircleAnimation"];
}


- (void)undoPieMask
{
    [self.contentLayer setContents:nil];

}

- (BOOL)isVisibleInRect:(CGRect)r
{
    // Check if there is an intersection between the layer's frame and the given rect.
    return CGRectIntersectsRect(r, self.layer.frame);
}

- (void)drawLayer:(CALayer*)l inContext:(CGContextRef)context
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    CGContextSaveGState(context);
    CGRect bounds = self.layer.bounds;
#ifdef DEBUG
    NSLog(@"%s: self.layer.bounds:%@", __FUNCTION__, NSStringFromCGRect(self.layer.bounds));
#endif
    CGFloat fullCirle = M_PI * 2.0;
    CGFloat startAngle = 0.0;
    CGFloat endAngle = fullCirle * maskPercentile;
    
    CGPoint center;
	center.x = bounds.size.width/2.0;
	center.y = bounds.size.height/2.0;
	float radius = bounds.size.width/2.0;
    //	float centerSize = radius * 3.5 / 10.0 ;
    
    UIBezierPath *path;
	path = [[UIBezierPath alloc] init];
	[path addArcWithCenter:center
                    radius:radius
                startAngle:startAngle
                  endAngle:endAngle
                 clockwise:YES];
    [path addLineToPoint:center];
	[path closePath];
    
    CGPathRef pathRef = [path CGPath];
    [self.maskLayer setPath:pathRef];
    CGContextRestoreGState(context);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - CAAnimation delegate

- (void)animationDidStart:(CAAnimation *)theAnimation
{
#ifdef DEBUG0
    NSLog(@"%s: theAnimation:%@", __FUNCTION__, theAnimation);
#endif
//	self.userInteractionEnabled = NO;
}

- (void)animationDidStop:(CAAnimation *)theAnimation
                finished:(BOOL)finished
{
#ifdef DEBUG0
    NSLog(@"%s: finished:%d, theAnimation:%@", __FUNCTION__, finished, theAnimation);
#endif
//    if (finished) {
//        double delayInSeconds = 2.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self lastHalfCircleAnimation];
//        });
//    }
//	self.userInteractionEnabled = YES;
}


@end
