/*
     File: MYVolumeUnitMeterView.h
 Abstract: Volume unit meter view
  Version: 1.0
 
 */

#import <UIKit/UIKit.h>

@interface MGLiveMeterView : UIView
@property (nonatomic) float value;
- (void)setupLayerTree;
@end
