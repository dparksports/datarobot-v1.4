/*
     File: MYVolumeUnitMeterView.m
 Abstract: Volume unit meter view
  Version: 1.0
*/

#import "MGLiveMeterView.h"

#import <QuartzCore/QuartzCore.h>

// This is an arbitrary calibration to define 0 db in the VU meter.
#define MYVolumeUnitMeterView_CALIBRATION 12.0f

#define DEGREE_TO_RADIAN M_PI / 180.0f

static CGFloat convertValueToNeedleAngle(CGFloat value);

@interface MGLiveMeterView () {
    BOOL constructed;
}
@property (readonly, strong, nonatomic) CALayer *needleLayer;
@end

@implementation MGLiveMeterView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
//		[self setupLayerTree];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
	{
//		[self setupLayerTree];
	}
	
	return self;
}

#define SCALE_NEEDLE 1.25

- (void)setupLayerTree
{
	CGRect viewLayerBounds = self.layer.bounds;
	
//#define SHOW_METER_BACKGROUND
#ifdef SHOW_METER_BACKGROUND
	self.layer.contents = (id)[[UIImage imageNamed:@"VUMeterBackground"] CGImage];
#endif
//    self.layer.opacity = .1;
	
	// Add shadow layer for needle.
	CALayer *shadowLayer = [CALayer layer];
	shadowLayer.shadowColor = [[UIColor orangeColor] CGColor];
	shadowLayer.shadowRadius = 0.0f;
	shadowLayer.shadowOffset = CGSizeMake(0.0f, 1.0f);
	shadowLayer.shadowOpacity = 1.0f;
	[self.layer addSublayer:shadowLayer];
	
	// Add needle layer.
	UIImage *needleImage = [UIImage imageNamed:@"VUMeterNeedle"];
	CGSize needleImageSize = [needleImage size];
	_needleLayer = [CALayer layer];
	[_needleLayer setContents:(id)[needleImage CGImage]];
	[_needleLayer setOpacity:1.0];
    
	CGAffineTransform transform = CGAffineTransformMakeScale(SCALE_NEEDLE, SCALE_NEEDLE);
	transform = CGAffineTransformRotate(transform, convertValueToNeedleAngle(-INFINITY));
	_needleLayer.affineTransform = transform;
	_needleLayer.anchorPoint = CGPointMake(0.5f, 1.0f);
	_needleLayer.bounds = CGRectMake(0.0f, 0.0f,
                                     needleImageSize.width, needleImageSize.height);
	_needleLayer.position = CGPointMake(CGRectGetWidth(viewLayerBounds) / 2.0,
                                        needleImageSize.height);
	[shadowLayer addSublayer:_needleLayer];

#define SHOW_PLASTIC_COVER
#ifdef SHOW_PLASTIC_COVER
	// Add foreground layer.
	CALayer *foregroundLayer = [CALayer layer];
	[foregroundLayer setOpacity:0.3];//0.1
	foregroundLayer.anchorPoint = CGPointZero;
	foregroundLayer.bounds = viewLayerBounds;
	foregroundLayer.contents = (id)[[UIImage imageNamed:@"VUMeterForeground"] CGImage];
	foregroundLayer.position = CGPointZero;
//	[self.layer addSublayer:foregroundLayer];
//	[self.layer insertSublayer:foregroundLayer below:_needleLayer];
	[self.layer insertSublayer:foregroundLayer above:_needleLayer];
#endif
}

#pragma mark -

- (void)setValue:(float)value
{
	if (_value != value)
	{
		_value = value;
		
		// Convert RMS amplitude into dB (using some arbitrary calibration values).
//		float valueDB = (20.0f * log10(value) + MYVolumeUnitMeterView_CALIBRATION);
		float valueDB = (25.0f * log10(value) + MYVolumeUnitMeterView_CALIBRATION);
		
        CGAffineTransform transform = CGAffineTransformMakeScale(SCALE_NEEDLE, SCALE_NEEDLE);
        transform = CGAffineTransformRotate(transform, convertValueToNeedleAngle(valueDB));
		_needleLayer.affineTransform = transform;
	}
}

@end

#pragma mark Functions

// Note: This calculation is just an approximation to map the artwork.
static CGFloat convertValueToNeedleAngle(CGFloat value)
{
	float degree = (value * 5.0f + 20.0f);
	
	// The mapping from dB amplitude to angle is not linear on our VU meter.
	if (value < -7.0f && value >= -10.0f)
		degree = (-15.0f + (10.0f / 3.0f) * (value + 7.0f));
	else if (value < -10.0f)
		degree = (-25.0f + (13.0f / 10.0f) * (value + 10.0f));
	
	// Limit to visible angle.
	degree = MAX(-38.0f, MIN(degree, 43.0f));
	
	return (DEGREE_TO_RADIAN * degree);
}
