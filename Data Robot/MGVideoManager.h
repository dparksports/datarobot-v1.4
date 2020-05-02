//
//  MGVideoManager.h
//  ROBO Meter
//
//  Created by Dan Park on 6/27/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface MGVideoManager : NSObject

+ (id)sharedInstance;
- (void)toggleTorchOnOff;

@end
