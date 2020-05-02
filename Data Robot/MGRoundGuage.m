//
//  MGRoundGuage.m
//  Data Robot
//
//  Created by Dan Park on 6/21/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGRoundGuage.h"

static inline double radians(double degrees) { return degrees * M_PI / 180; }

@implementation UIBezierPath (ShadowDrawing)

/* fill a bezier path, but draw a shadow under it offset by the
 given angle (counter clockwise from the x-axis) and distance. */
- (void)fillWithShadowAtDegrees:(float) angle withDistance:(float)distance {
	float radians = angle*(3.141592/180.0);
	
    /* create a new shadow */
	NSShadow* theShadow = [[NSShadow alloc] init];
	
    /* offset the shadow by the indicated direction and distance */
	[theShadow setShadowOffset:CGSizeMake(cosf(radians)*distance, sinf(radians)*distance)];
	
    /* set other shadow parameters */
	[theShadow setShadowBlurRadius:3.0];
	[theShadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    
    /* save the graphics context */
//	[NSGraphicsContext saveGraphicsState];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
	
    /* use the shadow */
//	[theShadow set];
    
    /* fill the NSBezierPath */
	[self fill];
	
    /* restore the graphics context */
//	[NSGraphicsContext restoreGraphicsState];
    CGContextRestoreGState(ctx);
	
    /* done with the shadow */
//	[theShadow release];
}

@end

@implementation MGRoundGuage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect boundary = self.frame;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGPoint center;
	center.x = boundary.size.width/2.0;
	center.y = boundary.size.height/2.0;
	float radius = boundary.size.width/2.0;
	float centerSize = radius * .8;
    
    UIBezierPath *path;
	path = [[UIBezierPath alloc] init];
	[path addArcWithCenter:center
                    radius:radius
                startAngle:radians(0)
                  endAngle:radians(360)
                 clockwise:YES];
    [path addLineToPoint:center];
	[path closePath];
    
	[path setLineWidth:1.];//0.5
	[path setLineJoinStyle:kCGLineJoinRound];
    [[UIColor colorWithWhite:0.7 alpha:1] set];
	[path fill];
    
	float sAngle = radians(-90);
	float eAngle = radians(180);
    
	path = [[UIBezierPath alloc] init];
	[path addArcWithCenter:center
                    radius:radius
                startAngle:sAngle
                  endAngle:eAngle
                 clockwise:YES];
    [path addLineToPoint:center];
	[path closePath];
    
	[path setLineWidth:1.];//0.5
	[path setLineJoinStyle:kCGLineJoinRound];
    [[UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:1] set];
	[path fill];
    
	path = [[UIBezierPath alloc] init];
	[path addArcWithCenter:center
                    radius:centerSize
                startAngle:radians(0)
                  endAngle:radians(360)
                 clockwise:YES];
    [path addLineToPoint:center];
	[path closePath];
	[path setLineWidth:1.];//0.5
	[path setLineJoinStyle:kCGLineJoinRound];
    [[UIColor whiteColor] set];
	[path fill];
    
    CGContextRestoreGState(ctx);
}

@end
