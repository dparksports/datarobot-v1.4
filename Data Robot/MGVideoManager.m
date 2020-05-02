//
//  MGVideoManager.m
//  ROBO Meter
//
//  Created by Dan Park on 6/27/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGVideoManager.h"

@interface MGVideoManager () {
    BOOL torchPoweredOn;
}
@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) id enteredBackgroundStateObserver;
@end


@implementation MGVideoManager


- (void)registerApplicationState
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    self.enteredBackgroundStateObserver = [center addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                   object:nil
                                                    queue:mainQueue
                                               usingBlock:^(NSNotification *note)
                                {
#ifdef DEBUG
                                    NSLog(@"%s", __FUNCTION__);
#endif
                                    torchPoweredOn = NO;
                                }];
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.enteredBackgroundStateObserver];
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

static id singleton;
+ (id)sharedInstance
{
    if (! singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          singleton = [[self.class alloc] init];
//                          [singleton setupSession];
                          [singleton registerApplicationState];
                      });
    }
    return singleton;
}

- (void)setupSession
{
    NSError *error = nil;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    
    // Create session (use default AVCaptureSessionPresetHigh)
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    
    [self setVideoInput:newVideoInput];
    [self setSession:newCaptureSession];
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void)autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([self respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [self captureManager:self didFailWithError:error];
            }
        }
    }
}

- (void)toggleTorchOnOff
{
    NSError *error = nil;
    BOOL succeeded = NO;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
//    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isTorchAvailable]) {
        succeeded = [device lockForConfiguration:&error];
        if (succeeded) {
            if (torchPoweredOn) {
                [device setTorchMode:AVCaptureTorchModeOff];
                torchPoweredOn = NO;
            } else {
                succeeded = [device setTorchModeOnWithLevel:AVCaptureMaxAvailableTorchLevel
                                          error:&error];
                if (succeeded) {
                    NSLog(@"%s: setTorchModeOnWithLevel: %@", __FUNCTION__, @"AVCaptureMaxAvailableTorchLevel");
                    torchPoweredOn = YES;
                } else {
                    [device setTorchMode:AVCaptureTorchModeOn];
                    NSLog(@"%s: setTorchModeOnWithLevel: %@", __FUNCTION__, error);
                    [self captureManager:self didFailWithError:error];
                    torchPoweredOn = YES;
                }
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"%s: lockForConfiguration: %@", __FUNCTION__, error);
            [self captureManager:self didFailWithError:error];
        }
    } else {
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Torch Not Available"
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                      otherButtonTitles:nil];
            [alertView show];
        });
    }
}

- (void)captureManager:(MGVideoManager *)videoManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}


@end
