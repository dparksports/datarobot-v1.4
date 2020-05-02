//
//  MGViewController.m
//  Data Robot
//
//  Created by Dan Park on 6/4/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
#include <mach/mach_time.h>

#import "MGUsageController.h"
#import "MGCurrentBillPeriod.h"
#import "MGDataManager.h"
#import "MGUsedPadController.h"
#import "MGDayPadController.h"
#import "MGQuotaPadController.h"
#import "MGVideoManager.h"
#import "MGLiveMeterController.h"
#import "MGCAShapeView.h"
#import "Flurry.h"


@interface MGUsageController (PadProtocols)
<MGQuotaPadProtocol, MGDayPadProtocol, MGUsedDataPadProtocol>
@end

@interface MGUsageController () <UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *usedDataLabel;
    __weak IBOutlet UILabel *maxDataLabel;
    __weak IBOutlet MGCAShapeView *shapeView;
    __weak IBOutlet UIImageView *greenStripCircle;
    __weak IBOutlet UILabel *percentLabel;
    __weak IBOutlet UILabel *percentUnitLabel;
    __weak IBOutlet UILabel *headerLabel;
    __weak IBOutlet UIButton *infoButton;
    __weak IBOutlet UIButton *dayButton;
    __weak IBOutlet UIButton *quotaButton;
    BOOL animateHelpButton;
    BOOL animatePieAfterChange;
}
@property (nonatomic, strong) NSTimer *frequencyTimer;
@property (nonatomic, strong) id activeStateObserver, resignStateObserver;
@end

@implementation MGUsageController

- (void)hidePieMask
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseIn;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:options
                     animations:^()
     {
         [greenStripCircle setAlpha:1];
         [shapeView setAlpha:0];
     }
                     completion:^(BOOL finished)
     {
         [shapeView undoPieMask];
     }];
}


- (void)showPieMask:(BOOL)animate
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager loadCurrentBillPeriod];
    // 7/2/2013: currentPeriodUsageString needs loadCurrentBillPeriod too.
    usedDataLabel.text = [manager currentPeriodUsageString];
    CGFloat percentile = [manager usedDataInPercentile];
    if (percentile < 1) {
        percentLabel.text = [NSString stringWithFormat:@"%.1f", percentile];
    } else {
        if (percentile < 10) {
            percentLabel.text = [NSString stringWithFormat:@"%.1f", percentile];
        } else {
            if (percentile < 95) {
                percentLabel.text = [NSString stringWithFormat:@"%.0f", percentile];
            } else {
                if (percentile < 100) {
                    percentLabel.text = [NSString stringWithFormat:@"%.1f", percentile];
                } else {
                    percentLabel.text = [NSString stringWithFormat:@"%.0f", percentile];
                }
            }
        }
    }

    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseIn;
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:options
                     animations:^()
     {
         [greenStripCircle setAlpha:0];
         [shapeView setAlpha:1];
     }
                     completion:^(BOOL finished)
     {
         [shapeView createContentLayer];
         [shapeView loadImageLayer];
         if (animate) {
             [shapeView animatePieMaskByPercentile:percentile / 100.0];
         } else {
             [shapeView applyPieMaskByPercentile:percentile / 100.0];
         }
         float usage = [manager adjustedCurrentDataUsageInFloat];
         if (usage == 0) {
             [self pulsateHelp:usedDataLabel finalFade:NO];
         }
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    animatePieAfterChange = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [greenStripCircle setAlpha:0];
    UIApplication *application = [UIApplication sharedApplication];
    if (application) {
        [application setIdleTimerDisabled:YES];
        [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)updateMeterByFrequency:(NSTimer*)timer {
    [self attempToSampleUsage];
    BOOL animate = NO;
    [self showPieMask:animate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    headerLabel.text = @"Used";
    percentUnitLabel.text = [NSString stringWithFormat:@"%%"];
    [infoButton setTitle:@"i" forState:UIControlStateNormal];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    self.activeStateObserver = [center addObserverForName:UIApplicationDidBecomeActiveNotification
                                                   object:nil
                                                    queue:mainQueue
                                               usingBlock:^(NSNotification *note)
                                {
#ifdef DEBUG0
                                    NSLog(@"%s", __FUNCTION__);
#endif
                                    [self attempToSampleUsage];
                                    BOOL animate = YES;
                                    [self showPieMask:animate];
                                }];
    
    self.resignStateObserver = [center addObserverForName:UIApplicationWillResignActiveNotification
                                                   object:nil
                                                    queue:mainQueue
                                               usingBlock:^(NSNotification *note)
                                {
#ifdef DEBUG0
                                    NSLog(@"%s", __FUNCTION__);
#endif
                                    [self hidePieMask];
                                }];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self attempToSampleUsage];
        BOOL animate = YES;
        [self showPieMask:animate];
    });
    
    if (! self.frequencyTimer) {
#define FREQUENCY_UPDATE_INTERVAL 1/1.0
        NSTimer *timer = [NSTimer timerWithTimeInterval:FREQUENCY_UPDATE_INTERVAL
                                                 target:self
                                               selector:@selector(updateMeterByFrequency:)
                                               userInfo:nil
                                                repeats:YES];
        NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
        [mainRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [self setFrequencyTimer:timer];
    }
    
    [Flurry logEvent:@"Usage"];
    [Flurry logPageView];
}

- (void)doublecheck
{
    double delayInSeconds = 60;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self attempToSampleUsage];
    });
}

- (void)attempToSampleUsage
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager uptimeByKernel];
    [manager sampleUsageAndUpdateRecords];
    BOOL clearedBootTimeUsage = [manager clearAndSaveBootTimeUsageIfNewPeriod];
    if (clearedBootTimeUsage) {
        headerLabel.text = @"New Month";
        [self pulsateLabel:headerLabel restoredLabel:@"Used" finalFade:YES];
        [manager sampleUsageAndUpdateRecords];
    }
    [self showPieMask:animatePieAfterChange];
    animatePieAfterChange = NO;
}

//- (void)attempToSampleUsageByAccelerator
//{
//#ifdef DEBUG
//    NSLog(@"%s", __FUNCTION__);
//#endif
//    // 7/2/2013: zero delay second repeats calling about 30 times until accelerometer is started.
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                   {
//                       // 6/26/13: wait until acelerometer timestamp is activated.
//                       MGDataManager *manager = [MGDataManager sharedInstance];
//                       //        [manager directTimestampByAccelerator];
//                       [manager uptimeByKernel];
//                       
//#define DELTA_SAMPLES_VARIATION 60
//                       if ([manager deltaBetweenSamples] <= DELTA_SAMPLES_VARIATION) {
//                           // lastBootDate still oscillates to the next mintue, use one second wait.
//                           [manager sampleUsageAndUpdateRecords];
//                           BOOL clearedBootTimeUsage = [manager clearAndSaveBootTimeUsageIfNewPeriod];
//                           if (clearedBootTimeUsage) {
//                               headerLabel.text = @"New Month";
//                               [self pulsateLabel:headerLabel restoredLabel:@"Used" finalFade:YES];
//                               [manager sampleUsageAndUpdateRecords];
//                           }
//                           [self showPieMask:animatePieAfterChange];
//                           animatePieAfterChange = NO;
//                           [self doublecheck];
//                       } else {
//                           // 6/12/13: acelerometer timestamp not ready, call it again in a second.
//                           [self attempToSampleUsage];
//                       }
//                   });
//}

- (void)viewDidUnload {
//    tableView = nil;
    usedDataLabel = nil;
    maxDataLabel = nil;
//    roundGauage = nil;
    shapeView = nil;
    greenStripCircle = nil;
    percentLabel = nil;
    percentUnitLabel = nil;
    infoButton = nil;
    dayButton = nil;
    quotaButton = nil;
    headerLabel = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.frequencyTimer invalidate];
    [self setFrequencyTimer:nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.activeStateObserver];
    [center removeObserver:self.resignStateObserver];
}

// -------------------------------------------------------------------------------
//	supportedInterfaceOrientations
//  Support only portrait orientation (iOS 6).
// -------------------------------------------------------------------------------
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// -------------------------------------------------------------------------------
//	shouldAutorotateToInterfaceOrientation
//  Support only portrait orientation (IOS 5 and below).
// -------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    MGDataManager *manager = [MGDataManager sharedInstance];
    NSArray *keys = [manager.bootTimes allKeys];
    return [keys count];
}

- (UITableViewCell *)handleStatsManager:(UITableView *)aTableView
                  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell*) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor colorWithWhite:1. alpha:1.]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:.7 alpha:1.]];
    }
    MGDataManager *manager = [MGDataManager sharedInstance];
    NSArray *keys = [manager.bootTimes allKeys];
    
//    NSDate *date = [keys objectAtIndex:indexPath.row];
//    NSArray *array = [manager.bootTimes objectForKey:date];
    NSString *dateString = [keys objectAtIndex:indexPath.row];
    NSArray *array = [manager.bootTimes objectForKey:dateString];
    
    NSNumber *sentNumber = [array objectAtIndex:0];
    NSNumber *receivedNumber = [array objectAtIndex:1];
    u_int64_t received = [receivedNumber unsignedLongLongValue];
    u_int64_t sent = [sentNumber unsignedLongLongValue];
    float BytesPerMB = 1024 * 1024;
    float receivedInUnit = received / BytesPerMB;
    float sentInUnit = sent / BytesPerMB;

    NSString *sentString = [NSString stringWithFormat:@"%.1f MB s", sentInUnit];
    NSString *receiveString = [NSString stringWithFormat:@"%.1f MB r", receivedInUnit];
    NSString *totalString = [NSString stringWithFormat:@"%.1f MB", receivedInUnit + sentInUnit];
    NSString *usageString = [NSString stringWithFormat:@"%@, %@, %@", totalString, receiveString, sentString];
    
//    NSString *dateString = [manager stringFromMediumTimeFormatter:date];
    NSString *headerString = [NSString stringWithFormat:@"Last Boot: %@", dateString];
    
    cell.textLabel.text = usageString;
    cell.detailTextLabel.text = headerString;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self handleStatsManager:aTableView cellForRowAtIndexPath:indexPath];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (0) {
            NSLog(@"%s", __FUNCTION__);
        }
    }
}

- (void)showAlertView:(NSString *)message
            withTitle:(NSString*)title
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Help", nil];
	
	[alertView show];
}

- (void)pulsateOnce:(UIView*)animatingView
{
#define Once_Animation 1
    CGFloat beginLevel = 1.0;
    CGFloat finalLevel = 0.0;
    CGFloat duration = 0.5;

    [animatingView setAlpha:beginLevel];
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:duration
                          delay:0.f
                        options:options
                     animations:^()
     {
         [animatingView setAlpha:finalLevel];
     }
                     completion:^(BOOL finished)
     {
//         [animatingView setAlpha:finalLevel];
     }];
}

- (void)pulsateHelp:(UIView*)animatingView finalFade:(BOOL)finalFade
{
#define Repeat_Animation 1
    CGFloat fadeLevel = 0.5;
    CGFloat finalLevel = 0.2;
    NSTimeInterval duration = 0.5;//1.5
    NSTimeInterval delay = 0.5;//2.0
    static uint8_t animateHelpCount = 0;
    [animatingView setAlpha:fadeLevel];
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:options
                     animations:^()
     {
         [animatingView setAlpha:0.05];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:duration
                               delay:delay
                             options:options
                          animations:^()
          {
              [animatingView setAlpha:fadeLevel];
          }
                          completion:^(BOOL finished)
          {
              animateHelpCount++;
              if (animateHelpCount < Repeat_Animation) {
                  [self pulsateHelp:animatingView finalFade:finalFade];
              } else {
                  [UIView animateWithDuration:duration
                                        delay:delay // 1.0
                                      options:options
                                   animations:^()
                   {
                       [animatingView setAlpha:(finalFade) ? finalLevel : 1];
                   }
                                   completion:^(BOOL finished)
                   {
                       animateHelpCount = 0;
                   }];
              }
          }];
     }];
}

- (void)pulsateLabel:(UILabel*)animatingLabel
       restoredLabel:(NSString*)restoredString
           finalFade:(BOOL)finalFade
{
#define Repeat_Animation 2
    CGFloat fadeLevel = 0.5;
    CGFloat finalLevel = 0.0;
    static uint8_t animateHelpCount = 0;
    [animatingLabel setAlpha:fadeLevel];
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:1.5f
                          delay:0.0f
                        options:options
                     animations:^()
     {
         [animatingLabel setAlpha:0.05];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:1.5f
                               delay:2.0f
                             options:options
                          animations:^()
          {
              [animatingLabel setAlpha:fadeLevel];
          }
                          completion:^(BOOL finished)
          {
              animateHelpCount++;
              if (animateHelpCount < Repeat_Animation) {
                  [self pulsateLabel:animatingLabel
                       restoredLabel:restoredString
                           finalFade:finalFade];
              } else {
                  [UIView animateWithDuration:1.5f
                                        delay:1.0f
                                      options:options
                                   animations:^()
                   {
                       [animatingLabel setAlpha:(finalFade) ? finalLevel : 1];
                   }
                                   completion:^(BOOL finished)
                   {
                       animateHelpCount = 0;
                       [animatingLabel setText:restoredString];
                       [UIView animateWithDuration:1.5f
                                             delay:1.0f
                                           options:options
                                        animations:^()
                        {
                            [animatingLabel setAlpha:(finalFade) ? 0.2 : 1];
                        }
                                        completion:^(BOOL finished)
                        {
                        }];
                   }];
              }
          }];
     }];
}

- (void)pulsateButton:(UIButton*)animatingButton
       restoredString:(NSString*)restoredString
           finalFade:(BOOL)finalFade
{
#define PULSALE_BUTTON_COUNT 1
    CGFloat visibleLevel = 0.5;
    CGFloat finalLevel = 0.0;
    static uint8_t animateHelpCount = 0;
    [animatingButton setAlpha:visibleLevel];
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:1.5f
                          delay:0.0f
                        options:options
                     animations:^()
     {
         [animatingButton setAlpha:0.05];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:1.5f
                               delay:2.0f
                             options:options
                          animations:^()
          {
              [animatingButton setAlpha:visibleLevel];
          }
                          completion:^(BOOL finished)
          {
              animateHelpCount++;
              if (animateHelpCount < PULSALE_BUTTON_COUNT) {
                  [self pulsateButton:animatingButton
                       restoredString:restoredString
                           finalFade:finalFade];
              } else {
                  [UIView animateWithDuration:1.5f
                                        delay:1.0f
                                      options:options
                                   animations:^()
                   {
                       [animatingButton setAlpha:(finalFade) ? finalLevel : 1];
                   }
                                   completion:^(BOOL finished)
                   {
                       animateHelpCount = 0;
                       [animatingButton setTitle:restoredString forState:UIControlStateNormal];
                       [UIView animateWithDuration:1.5f
                                             delay:1.0f
                                           options:options
                                        animations:^()
                        {
                            [animatingButton setAlpha:(finalFade) ? 0.2 : 1];
                        }
                                        completion:^(BOOL finished)
                        {
                        }];
                   }];
              }
          }];
     }];
}


#pragma mark IBAction

- (IBAction)openLiveMeter:(id)sender
{
    MGLiveMeterController *content = [[MGLiveMeterController alloc] initWithNibName:@"MGLiveMeterController" bundle:nil];
    content.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:content
                       animated:YES
                     completion:^{
                     }];
}

- (IBAction)toggleTorch:(id)sender
{
//    MGVideoManager *manager = [MGVideoManager sharedInstance];
//    [manager toggleTorchOnOff];
    [self pulsateOnce:greenStripCircle];
}

- (IBAction)showUsedVC:(id)sender {
//    MGUsedPadController *content = [self.storyboard instantiateViewControllerWithIdentifier:@"MGUsedPadControllerID"];
    MGUsedPadController *content = [[MGUsedPadController alloc] initWithNibName:@"MGUsedPadController"
                                                                           bundle:nil];
    [content setDelegate:self];
    content.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:content
                       animated:YES
                     completion:^{
                     }];
}

- (IBAction)showQuotaVC:(id)sender {
//    MGQuotaPadController *content = [self.storyboard instantiateViewControllerWithIdentifier:@"MGQuotaPadControllerID"];
    MGQuotaPadController *content = [[MGQuotaPadController alloc] initWithNibName:@"MGQuotaPadController"
                                                                           bundle:nil];
    [content setDelegate:self];
    content.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:content
                       animated:YES
                     completion:^{
                         MGDataManager *manager = [MGDataManager sharedInstance];
                         [manager loadCurrentBillPeriod];
                         MGCurrentBillPeriod *billPeriod = [manager currentBillPeriod];
                         NSNumber *number = [billPeriod dataQuotaInMB];
                         NSUInteger dataQuotaInMB = [number unsignedIntegerValue];
                         [content updateValue:dataQuotaInMB];
                     }];
}

- (IBAction)showDayVC:(id)sender {
    MGDayPadController *content = [[MGDayPadController alloc] initWithNibName:@"MGDayPadController"
                                                                       bundle:nil];
    [content setDelegate:self];

    content.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:content
                       animated:YES
                     completion:^{
                         MGDataManager *manager = [MGDataManager sharedInstance];
                         [manager loadCurrentBillPeriod];
                         MGCurrentBillPeriod *billPeriod = [manager currentBillPeriod];
                         NSNumber *billDayOfMonth = [billPeriod billDayOfMonth];
                         NSUInteger resetDay = [billDayOfMonth unsignedIntegerValue];
                         [content updateValue:resetDay];
                     }];
}

#pragma mark - MGUsedDataPadProtocol

- (void)updateUsedData:(float)dataUsedInUnit
{
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager loadCurrentBillPeriod];
    [manager saveTodayInBillRecord];
    
    float currentUsageInMB = [manager nonAdjustedCurrentDataUsageInFloat];
    float diffUsedDataInMB = dataUsedInUnit - currentUsageInMB;
    [manager updateCurrentBillPeriodWithAdjustedDataUsage:diffUsedDataInMB];
    [manager saveCurrentBillPeriod];
    usedDataLabel.text = [manager currentPeriodUsageString];
    animatePieAfterChange = YES;

#ifdef DEBUG
    NSLog(@"%s: diffUsedDataInMB:%lf = dataUsedInUnit:%lf - currentUsageInMB:%lf", __FUNCTION__,
          diffUsedDataInMB, dataUsedInUnit, currentUsageInMB);
#endif
}

#pragma mark - MGDayPadProtocol

- (void)updateResetDay:(NSUInteger)resetDay
{
#ifdef DEBUG
    NSLog(@"%s: resetDay:%d", __FUNCTION__, resetDay);
#endif
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager loadCurrentBillPeriod];
    [manager saveTodayInBillRecord];
    [manager updateCurrentBillPeriod:resetDay];
    [manager saveCurrentBillPeriod];
    
    NSString *dayString = nil;
    switch (resetDay) {
        case 1:
        {
            dayString = [NSString stringWithFormat:@"%dst Day", resetDay];
        }
            break;
        case 2:
        {
            dayString = [NSString stringWithFormat:@"%dnd Day", resetDay];
        }
            break;
        case 3:
        {
            dayString = [NSString stringWithFormat:@"%drd Day", resetDay];
        }
            break;
            
        default:
        {
            dayString = [NSString stringWithFormat:@"%dth Day", resetDay];
        }
            break;
    }
    [dayButton setTitle:dayString forState:UIControlStateNormal];
//    [self pulsateHelp:dayButton finalFade:YES];
    MGCurrentBillPeriod *billPeriod = [manager currentBillPeriod];
    NSInteger daysToReset = [billPeriod daysToReset];
    NSString *string;
    if (daysToReset > 1) {
        string = [NSString stringWithFormat:@"%d Days Left", daysToReset];
    } else {
        string = [NSString stringWithFormat:@"%d Day Left", daysToReset];
    }
    [self pulsateButton:dayButton restoredString:string finalFade:YES];
}

#pragma mark - MGQuotaPadProtocol

- (void)updateDataQuota:(NSUInteger)quotaInMB
{
#ifdef DEBUG
    NSLog(@"%s: quotaInMB:%u", __FUNCTION__, quotaInMB);
#endif
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager loadCurrentBillPeriod];
    [manager saveTodayInBillRecord];
    [manager updateDataQuotaInMB:quotaInMB];
    [manager saveCurrentBillPeriod];
    
    animatePieAfterChange = YES;
    NSString *string = [NSString stringWithFormat:@"%d MB", quotaInMB];
    [quotaButton setTitle:string forState:UIControlStateNormal];
    [self pulsateHelp:quotaButton finalFade:YES];
}
@end