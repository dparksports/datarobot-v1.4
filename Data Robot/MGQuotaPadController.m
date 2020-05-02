//
//  MGQuotaPadController.m
//  ROBO
//
//  Created by Dan Park on 6/22/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGQuotaPadController.h"
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

@interface MGQuotaPadController () {
    IBOutlet UILabel *digitalLabel;
    IBOutlet UIImageView *backdropView;
    IBOutlet UILabel *backdropLabel;
    IBOutlet UILabel *headerLabel;
    IBOutlet UIButton *button1;
    IBOutlet UIButton *button2;
    IBOutlet UIButton *button3;
    IBOutlet UIButton *button4;
    IBOutlet UIButton *button5;
    IBOutlet UIButton *button6;
    IBOutlet UIButton *button7;
    IBOutlet UIButton *button8;
    IBOutlet UIButton *button9;
    IBOutlet UIButton *button10;
    IBOutlet UIButton *buttonClear;
    IBOutlet UIButton *buttonBackDelete;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonSave;
    NSUInteger lengthLimit;
}
@property (retain, nonatomic) NSMutableString *timeString;
@property (retain, nonatomic) NSMutableString *displayString;
@property (readwrite, nonatomic) NSInteger commandTag;
@end

@implementation MGQuotaPadController

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
#define NumericLengthLimit 5
    lengthLimit = NumericLengthLimit;
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
    NSLog(@"%s: ionfont:%@", __FUNCTION__, [ionfont description]);
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
    [digitalLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.9f]];

    
#ifdef DEBUG0
    [backdropView setHidden:YES];
#else
    [backdropView setHidden:NO];
#endif
    
#define Enable_Quartz
#ifdef Enable_Quartz
    CALayer *gradientLayer = nil;
    gradientLayer = [button1 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button2 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button3 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button4 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button5 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button6 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button7 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button8 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button9 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [button10 layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [buttonClear layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [buttonBackDelete layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [buttonCancel layer];
    [self applyQuartzLayer:gradientLayer];
    gradientLayer = [buttonSave layer];
    [self applyQuartzLayer:gradientLayer];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"QuotaPad"];
    [Flurry logPageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    digitalLabel = nil;
    backdropLabel = nil;
    headerLabel = nil;
    button1 = nil;
    button2 = nil;
    button3 = nil;
    button4 = nil;
    button5 = nil;
    button6 = nil;
    button7 = nil;
    button8 = nil;
    button9 = nil;
    button10 = nil;
    buttonClear = nil;
    buttonBackDelete = nil;
    buttonCancel = nil;
    buttonSave = nil;
    backdropView = nil;
    [super viewDidUnload];
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

- (NSString*)processString {
    NSScanner *scanner = [NSScanner scannerWithString:_timeString];
    NSInteger score;
    if ([scanner scanInteger:&score]) {
        NSZone *copyZone = NULL;
        NSNumber *number = [NSNumber numberWithInteger:score];
        NSString *normalizedString = [number stringValue];
        NSMutableString *mutableString = [normalizedString mutableCopyWithZone:copyZone];
#ifdef DEBUG0
        NSLog(@"%s: mutableString:%@", __FUNCTION__, [mutableString description]);
#endif
        [self setTimeString:mutableString];
    }
    
    NSZone *copyZone = NULL;
    if ([_timeString length] > lengthLimit) {
        NSRange range = NSMakeRange(0, lengthLimit);
        NSString *immutable = [_timeString substringWithRange:range];
        _timeString = [immutable mutableCopyWithZone:copyZone];
#ifdef DEBUG0
        NSLog(@"%s: _timeString:%@", __FUNCTION__, [_timeString description]);
#endif
    }
    _displayString = [_timeString mutableCopyWithZone:copyZone];
#ifdef DEBUG0
    NSLog(@"%s: _displayString:%@", __FUNCTION__, [_displayString description]);
#endif
    return _displayString;
}

- (void)resetValue{
    NSString *emptyString = [NSString string];
    [_timeString setString:emptyString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (void)updateValue:(NSUInteger)value {
    NSString *localizedString = [NSString stringWithFormat:@"%d", value];
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

#pragma mark - IBAction

- (IBAction)tappedButtonBackDelete:(id)sender {
    NSUInteger length = [_timeString length];
    NSInteger lessLength = length-1;
    if (lessLength < 0) {
        NSString *immutable = @"";
        _timeString = [immutable mutableCopyWithZone:NULL];
    } else {
        NSRange range = NSMakeRange(0, lessLength);
        NSString *immutable = [_timeString substringWithRange:range];
        _timeString = [immutable mutableCopyWithZone:NULL];
    }
#ifdef DEBUG
    NSLog(@"%s: _timeString:%@", __FUNCTION__, [_timeString description]);
#endif
    
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButtonClear:(id)sender {
    NSString *emptyString = [NSString string];
    [_timeString setString:emptyString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton1:(id)sender {
    NSString *localizedString = NSLocalizedString(@"1", @"1");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton2:(id)sender {
    NSString *localizedString = NSLocalizedString(@"2", @"2");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton3:(id)sender {
    NSString *localizedString = NSLocalizedString(@"3", @"3");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton4:(id)sender {
    NSString *localizedString = NSLocalizedString(@"4", @"4");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton5:(id)sender {
    NSString *localizedString = NSLocalizedString(@"5", @"5");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton6:(id)sender {
    NSString *localizedString = NSLocalizedString(@"6", @"6");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton7:(id)sender {
    NSString *localizedString = NSLocalizedString(@"7", @"7");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton8:(id)sender {
    NSString *localizedString = NSLocalizedString(@"8", @"8");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton9:(id)sender {
    NSString *localizedString = NSLocalizedString(@"9", @"9");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton0:(id)sender {
    NSString *localizedString = NSLocalizedString(@"0", @"0");
    [_timeString appendString:localizedString];
    [self processString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButtonCancel:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self dismissModalViewControllerAnimated:YES];
    });
}

- (IBAction)tappedButtonSave:(id)sender {
    NSScanner *scanner = [NSScanner scannerWithString:_displayString];
    NSInteger scoreInteger = 0;
    if ([scanner scanInteger:&scoreInteger]) {
        _updatedQuotaInMB = scoreInteger;
    } else {
        _updatedQuotaInMB = 0;
    }
#ifdef DEBUG
    NSLog(@"%s: _updatedQuotaInMB:%d", __FUNCTION__, _updatedQuotaInMB);
#endif
    SEL sel = @selector(updateDataQuota:);
    if ([self.delegate respondsToSelector:sel]) {
        [self.delegate updateDataQuota:_updatedQuotaInMB];
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
