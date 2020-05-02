//
//  MGUsedPadController.m
//  Data Robot
//
//  Created by Dan Park on 6/26/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGUsedPadController.h"
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

@interface MGUsedPadController () {
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
    __weak IBOutlet UILabel *dataUnitLabel;
}
@property (retain, nonatomic) NSMutableString *timeString;
@property (retain, nonatomic) NSMutableString *displayString;
@property (readwrite, nonatomic) NSInteger commandTag;
@end

@implementation MGUsedPadController

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
    [digitalLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.9f]];

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
    [Flurry logEvent:@"About"];
    [Flurry logPageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
//    [digitalLabel release];
    digitalLabel = nil;
//    [backdropLabel release];
    backdropLabel = nil;
//    [headerLabel release];
    headerLabel = nil;
//    [button1 release];
    button1 = nil;
//    [button2 release];
    button2 = nil;
//    [button3 release];
    button3 = nil;
//    [button4 release];
    button4 = nil;
//    [button5 release];
    button5 = nil;
//    [button6 release];
    button6 = nil;
//    [button7 release];
    button7 = nil;
//    [button8 release];
    button8 = nil;
//    [button9 release];
    button9 = nil;
//    [button10 release];
    button10 = nil;
//    [buttonClear release];
    buttonClear = nil;
//    [buttonBackDelete release];
    buttonBackDelete = nil;
//    [buttonCancel release];
    buttonCancel = nil;
//    [buttonSave release];
    buttonSave = nil;
//    [backdropView release];
    backdropView = nil;
    dataUnitLabel = nil;
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

- (NSString*)processTimeString {
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

- (void)resetValue{
    NSString *emptyString = [NSString string];
    [_timeString setString:emptyString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (void)updateValue:(NSUInteger)value {
    NSString *localizedString = [NSString stringWithFormat:@"%d", value];
    [_timeString appendString:localizedString];
    [self processTimeString];
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
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButtonClear:(id)sender {
    NSString *emptyString = [NSString string];
    [_timeString setString:emptyString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton1:(id)sender {
    NSString *localizedString = NSLocalizedString(@"1", @"1");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton2:(id)sender {
    NSString *localizedString = NSLocalizedString(@"2", @"2");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton3:(id)sender {
    NSString *localizedString = NSLocalizedString(@"3", @"3");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton4:(id)sender {
    NSString *localizedString = NSLocalizedString(@"4", @"4");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton5:(id)sender {
    NSString *localizedString = NSLocalizedString(@"5", @"5");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton6:(id)sender {
    NSString *localizedString = NSLocalizedString(@"6", @"6");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton7:(id)sender {
    NSString *localizedString = NSLocalizedString(@"7", @"7");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton8:(id)sender {
    NSString *localizedString = NSLocalizedString(@"8", @"8");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton9:(id)sender {
    NSString *localizedString = NSLocalizedString(@"9", @"9");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButton0:(id)sender {
    NSString *localizedString = NSLocalizedString(@"0", @"0");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButtonPeriod:(id)sender
{
    NSString *localizedString = NSLocalizedString(@".", @".");
    [_timeString appendString:localizedString];
    [self processTimeString];
    [digitalLabel setText:[_displayString description]];
}

- (IBAction)tappedButtonGB:(id)sender
{
    [dataUnitLabel setText:@"GB"];
}

- (IBAction)tappedButtonMB:(id)sender
{
    [dataUnitLabel setText:@"MB"];
}

- (IBAction)tappedButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){
    }];
}

- (IBAction)tappedButtonSave:(id)sender
{
    _dataUsedInUnit = 0;
    NSCharacterSet *commaSet = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSArray *components = [_displayString componentsSeparatedByCharactersInSet:commaSet];
    NSMutableString *mutableString = [[components objectAtIndex:0] mutableCopy];
    if ([components count] > 1) {
        NSString *lastString = [components objectAtIndex:1];
        [mutableString appendString:lastString];
    }
    
    float dataUsedInMB = 0;
    _dataUsedInUnit = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:mutableString];
    BOOL success = [scanner scanFloat:&dataUsedInMB];
    if (success) {
        _dataUsedInUnit = dataUsedInMB;
    }

#ifdef DEBUG
    NSLog(@"%s: _dataUsedInUnit:%.3f", __FUNCTION__, _dataUsedInUnit);
#endif
    
    SEL sel = @selector(updateUsedData:);
    if ([self.delegate respondsToSelector:sel]) {
        [self.delegate updateUsedData:_dataUsedInUnit];
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
