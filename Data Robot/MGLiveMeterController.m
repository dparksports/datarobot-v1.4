//
//  SNLTimePadController.m
//  Scoreboard
//
//  Created by Dan Park on 3/5/13.
//  Copyright (c) 2013 TST Media. All rights reserved.
//

#import "MGLiveMeterController.h"
#import "MGLiveMeterView.h"
#import "MGRoundGuage.h"
#import "MGDataManager.h"
#import "Flurry.h"

#define BoldIonFontName @"IONC-Bold"
#define MediumIonFontName @"IONC-Medium"
#define SemiBoldIonFontName @"IONC-Semibold"
#define RegularIonFontName @"IONC-Regular"
#define MediumVitesseFontName @"Vitesse-Medium"
#define BoldVitesseFontName @"Vitesse-Bold"
#define BookVitesseFontName @"Vitesse-Book"
#define BlackVitesseFontName @"Vitesse-Black"
#define BoldProximaFontName @"ProximaNova-Bold"
#define RegularProximaFontName @"ProximaNova-Regular"
#define LightProximaFontName @"ProximaNova-Light"
#define SemiboldProximaFontName @"ProximaNova-Semibold"
#define ThinProximaFontName @"ProximaNova-Thin"
#define IonFontFamily @"ION C"
#define VitesseFontFamily @"Vitesse"
#define ProximaFontFamily @"Proxima Nova"
#define DisplayFontSize 58  //58
#define HeaderFontSize 18
#define ButtonFontSize 42   //38
#define SaveFontSize 18
#define ClearFontSize 12

@interface MGLiveMeterController () {
    IBOutlet UILabel *digitalLabel;
    IBOutlet UIImageView *backdropView;
    IBOutlet UILabel *backdropLabel;
    IBOutlet UILabel *headerLabel;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonSave;
    __weak IBOutlet MGLiveMeterView *liveMeter;
    __weak IBOutlet UILabel *unitLabel;
    __weak IBOutlet UISwitch *monitorCellularSwitch;
    __weak IBOutlet UISwitch *monitorWifiSwitch;
    __weak IBOutlet UISwitch *showIncomingDataSwitch;
    __weak IBOutlet UISwitch *showOutgoingDataSwitch;
    __weak IBOutlet UILabel *unitMBLabel;
    __weak IBOutlet UILabel *unitKBLabel;
    __weak IBOutlet UILabel *unitBytesLabel;
}
@property (retain, nonatomic) NSTimer *frequencyTimer;
@property (retain, nonatomic) NSMutableString *timeString;
@property (retain, nonatomic) NSMutableString *displayString;
@end

@implementation MGLiveMeterController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [self setTimeString:mutableString];
//    [mutableString release];
    
    NSArray *familyFonts = [UIFont familyNames];
    for (id fontName in familyFonts) {
#ifdef DEBUG0
        NSLog(@"%@\n\n", [fontName description]);
#endif
    }
    
    familyFonts = [UIFont fontNamesForFamilyName:IonFontFamily];
    for (id fontName in familyFonts) {
#ifdef DEBUG0
        NSLog(@"%@", [fontName description]);
#endif
    }
    
    familyFonts = [UIFont fontNamesForFamilyName:VitesseFontFamily];
    for (id fontName in familyFonts) {
#ifdef DEBUG0
        NSLog(@"%@", [fontName description]);
#endif
    }
    
    familyFonts = [UIFont fontNamesForFamilyName:ProximaFontFamily];
    for (id fontName in familyFonts) {
#ifdef DEBUG0
        NSLog(@"%@", [fontName description]);
#endif
    }

}

- (void)applyQuartzLayer:(id)layer {
#ifdef DEBUG0
    NSLog(@"%@", [layer description]);
#endif
    CGColorSpaceRef deviceColorSpace = CGColorSpaceCreateDeviceRGB();
#ifdef DEBUG0
//    CGFloat outlineComponents[] = {255/255.f, 0/1.f, 0/1.f, 255/255.f};
    CGFloat outlineFactor = 1.f;//10
#else
    CGFloat outlineFactor = 1.f;
#endif
    CGFloat shadowComponents[] = {0/1.f, 0/1.f, 0/1.f, 255/255.f};
    CGColorRef shadowRef = CGColorCreate(deviceColorSpace, shadowComponents);
    CALayer *buttonLayer = layer;
    [buttonLayer setShadowColor:shadowRef];
    [buttonLayer setMasksToBounds:NO];
    CGFloat opacity = 4/5.0f;
    [buttonLayer setShadowOpacity:opacity];
    CGSize offset = CGSizeMake(1/-1.f*outlineFactor, 0);
    [buttonLayer setShadowOffset:offset];
    CGFloat radius = offset.width * -1.0f;
    [buttonLayer setShadowRadius:radius];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIFont *ionfont = [UIFont fontWithName:BoldIonFontName size:DisplayFontSize];
#ifdef DEBUG0
    NSLog(@"%s: ionfont:%@", __func__, [ionfont description]);
#endif
    CGColorSpaceRef deviceColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {255/255.f, 255/255.f, 255/255.f, 1/20.f};
    CGColorRef colorRef = CGColorCreate(deviceColorSpace, components);
    UIColor *opacityColor = [UIColor colorWithCGColor:colorRef];
    [backdropLabel setTextColor:opacityColor];
    [backdropLabel setTextAlignment:NSTextAlignmentRight];
    [backdropLabel setFont:ionfont];
    [backdropLabel setHidden:NO];
    [digitalLabel setFont:ionfont];
    [digitalLabel setTextAlignment:NSTextAlignmentRight];
    [digitalLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.7f]];//0.7

    [unitBytesLabel setAlpha:0.1];
    [unitKBLabel setAlpha:0.1];
    [unitMBLabel setAlpha:0.1];
    
#ifdef USE_CUSTOM_FONTS
    UILabel *buttonLabel;
    buttonLabel = [buttonClear titleLabel];
    [buttonLabel setFont:clearFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [buttonSave titleLabel];
    [buttonLabel setFont:saveFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [buttonCancel titleLabel];
    [buttonLabel setFont:saveFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [buttonBackDelete titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    
    buttonLabel = [button1 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button2 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button3 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button4 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button5 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button6 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button7 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button8 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button9 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
    buttonLabel = [button10 titleLabel];
    [buttonLabel setFont:buttonFont];
    [buttonLabel setTextAlignment:NSTextAlignmentCenter];
#endif
    
#ifdef DEBUG0
    [backdropView setHidden:YES];
#else
    [backdropView setHidden:NO];
#endif
    
#define Enable_Quartz
#ifdef Enable_Quartz
    CALayer *gradientLayer = nil;
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [buttonCancel layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [buttonSave layer];
    [self applyQuartzLayer:gradientLayer];
#endif
    
#ifdef USE_BACKBUTTON
    id target = nil;
    SEL sel = nil;
    UIBarButtonItemStyle style = UIBarButtonItemStyleBordered;
    NSString *text = NSLocalizedString(@"Back", @"Back");
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:text
                                                                   style:style
                                                                  target:target
                                                                  action:sel];
    self.navigationItem.backBarButtonItem = buttonItem;
#endif
//    [buttonItem release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [liveMeter setupLayerTree];
    
    if (! self.frequencyTimer) {
#define FREQUENCY_UPDATE_INTERVAL 1/2.0  // 3.0:less needle movement
        NSTimer *timer = [NSTimer timerWithTimeInterval:FREQUENCY_UPDATE_INTERVAL
                                                 target:self
                                               selector:@selector(updateMeterByFrequency:)
                                               userInfo:nil
                                                repeats:YES];
        NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
        [mainRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [self setFrequencyTimer:timer];
    }
    [Flurry logEvent:@"Live Meter"];
    [Flurry logPageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
}

- (void)viewDidUnload
{
    [self.frequencyTimer invalidate];
    [self setFrequencyTimer:nil];
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    digitalLabel = nil;
    backdropLabel = nil;
    headerLabel = nil;
    buttonCancel = nil;
    buttonSave = nil;
    backdropView = nil;
    liveMeter = nil;
    unitLabel = nil;
    monitorCellularSwitch = nil;
    monitorWifiSwitch = nil;
    showIncomingDataSwitch = nil;
    showOutgoingDataSwitch = nil;
    unitMBLabel = nil;
    unitKBLabel = nil;
    unitBytesLabel = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    [self.frequencyTimer invalidate];
    [self setFrequencyTimer:nil];
}

- (NSString*)processTimeString
{
    const NSUInteger commandIndex = 5;
    const NSUInteger limit = commandIndex+1;
    const NSUInteger periodIndex = 1;
    NSZone *copyZone = NULL;
    if ([_timeString length] >= limit) {
        NSRange range = NSMakeRange(0, commandIndex+1);
        NSString *immutable = [_timeString substringWithRange:range];
        _timeString = [immutable mutableCopyWithZone:copyZone];
    }
    _displayString = [_timeString mutableCopyWithZone:copyZone];
    if ([_displayString length] >= periodIndex+1) {
#define PeriodDelimiter @"."
        const NSUInteger indexNMinus = [_displayString length] - periodIndex;
        [_displayString insertString:PeriodDelimiter atIndex:indexNMinus];
        
        if ([_displayString length] >= commandIndex+1) {
#define CommaDelimiter @","
            const NSUInteger indexNMinus = [_displayString length] - commandIndex;
            [_displayString insertString:CommaDelimiter atIndex:indexNMinus];

            const NSUInteger appendedCount = 2;
            if ([_timeString length] > commandIndex+2+appendedCount) {
#define EmptyString @""
                NSUInteger permittedLength = 5;
                NSString *immutable = [_displayString copyWithZone:NULL];
                immutable = [immutable stringByPaddingToLength:permittedLength withString:EmptyString startingAtIndex:0];
                _displayString = [immutable mutableCopyWithZone:copyZone];
            }
        }
    }
    return _displayString;
}

- (void)updateValue:(NSString*)string
{
    [_timeString setString:string];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (void)updateMeterByFrequency:(NSTimer*)timer
{
    static u_int64_t lastReceivedWifi = 0;
    static u_int64_t lastSentWifi = 0;
    static u_int64_t lastReceivedWAN = 0;
    static u_int64_t lastSentWAN = 0;
    
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager sampleNetworkInterfaces];
    u_int64_t receivedWifiInUnit = [manager receivedWifiInUnit];
    u_int64_t sentWifiInUnit = [manager sentWifiInUnit];
    u_int64_t receivedWANInUnit = [manager receivedWANInUnit];
    u_int64_t sentWANInUnit = [manager sentWANInUnit];
    
    lastReceivedWifi = (lastReceivedWifi == 0) ? receivedWifiInUnit : lastReceivedWifi;
    lastSentWifi = (lastSentWifi == 0) ? sentWifiInUnit : lastSentWifi;
    lastReceivedWAN = (lastReceivedWAN == 0) ? receivedWANInUnit : lastReceivedWAN;
    lastSentWAN = (lastSentWAN == 0) ? sentWANInUnit : lastSentWAN;
    
    float diffReceivedWifi = receivedWifiInUnit - lastReceivedWifi;
    float diffSentWifi = sentWifiInUnit - lastSentWifi;
    float diffReceivedWAN = receivedWANInUnit - lastReceivedWAN;
    float diffSentWAN = sentWANInUnit - lastSentWAN;
    
    lastReceivedWifi = receivedWifiInUnit;
    lastSentWifi = sentWifiInUnit;
    lastReceivedWAN = receivedWANInUnit;
    lastSentWAN = sentWANInUnit;
    
    float diffSum = 0;
    if (showIncomingDataSwitch.isOn) {
        if (monitorCellularSwitch.isOn) {
            diffSum += diffReceivedWAN;
        } else {
            diffSum += diffReceivedWifi;
        }
    }
    if (showOutgoingDataSwitch.isOn) {
        if (monitorCellularSwitch.isOn) {
            diffSum += diffSentWAN;
        } else {
            diffSum += diffSentWifi;
        }
    }
    CGFloat showAlphaLevel = 0.7;
    CGFloat fadedAlphaLevel = 0.2;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    if (diffSum < 1024) {
        [liveMeter setValue:diffSum / 1024.0];
        unitLabel.text = @"B";
        NSString *normalizePrecisionDigit = [NSString stringWithFormat:@"%.0f", diffSum * 10];
        [self updateValue:normalizePrecisionDigit];
        [UIView animateWithDuration:0.5f
                              delay:0.f
                            options:options
                         animations:^()
         {
             [unitBytesLabel setAlpha:showAlphaLevel];
             [unitKBLabel setAlpha:fadedAlphaLevel];
             [unitMBLabel setAlpha:fadedAlphaLevel];
         }
                         completion:^(BOOL finished) {}];
        
    } else {
        float valueInKB = diffSum / 1024.0;
        if (valueInKB < 1024) {
            [liveMeter setValue:valueInKB / 1024.0];
            unitLabel.text = @"KB";
            NSString *normalizePrecisionDigit = [NSString stringWithFormat:@"%.0f", valueInKB * 10];
            [self updateValue:normalizePrecisionDigit];
            [UIView animateWithDuration:0.5f
                                  delay:0.f
                                options:options
                             animations:^()
             {
                 [unitBytesLabel setAlpha:fadedAlphaLevel];
                 [unitKBLabel setAlpha:showAlphaLevel];
                 [unitMBLabel setAlpha:fadedAlphaLevel];
             }
                             completion:^(BOOL finished) {}];
        }
        else
        {
            float valueInMB = diffSum / (1024 * 1024.0);
            [liveMeter setValue:valueInMB / 1024.0];
            unitLabel.text = @"MB";
            NSString *normalizePrecisionDigit = [NSString stringWithFormat:@"%.0f", valueInMB * 10];
            [self updateValue:normalizePrecisionDigit];
            [UIView animateWithDuration:0.5f
                                  delay:0.f
                                options:options
                             animations:^()
             {
                 [unitBytesLabel setAlpha:fadedAlphaLevel];
                 [unitKBLabel setAlpha:fadedAlphaLevel];
                 [unitMBLabel setAlpha:showAlphaLevel];
             }
                             completion:^(BOOL finished) {}];
        }
    }
    
#ifdef DEBUG0
    NSLog(@"%s: diffSum: %.1f", __FUNCTION__, diffSum);
#endif
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

#pragma mark - IBAction

- (IBAction)toggleTrafficMonitor:(id)sender {
    UISwitch *trafficSwitch = (UISwitch*)sender;
    if (trafficSwitch == monitorCellularSwitch) {
        monitorWifiSwitch.on = ! monitorCellularSwitch.on;
    }
    if (trafficSwitch == monitorWifiSwitch) {
        monitorCellularSwitch.on = ! monitorWifiSwitch.on;
    }
}

- (IBAction)tappedButtonCancel:(id)sender {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^() {
        [self dismissModalViewControllerAnimated:YES];
    });
}

- (IBAction)tappedButtonSave:(id)sender {

}
@end
