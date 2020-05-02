//
//  MGDiagnosicController.m
//  Meter Robot
//
//  Created by Dan Park on 6/30/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGDiagnosicController.h"
#import "MGDataManager.h"
#import "MGCurrentBillPeriod.h"
#import "Flurry.h"

@interface MGDiagnosicController ()
{
    __weak IBOutlet UILabel *digitalLabel;
    __weak IBOutlet UILabel *backdropLabel;
    __weak IBOutlet UILabel *unitLabel;
    __weak IBOutlet UITableView *tableView;
    NSArray *sortedKeys;
}
@end

@implementation MGDiagnosicController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#define BoldIonFontName @"IONC-Bold"
#define DisplayFontSize 58
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
    
    MGDataManager *manager = [MGDataManager sharedInstance];
    digitalLabel.text = [manager currentPeriodUsageString];
    backdropLabel.text = [manager maskStringForDataUsage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    sortedKeys = [self sortAllKeys:NSOrderedAscending];
    sortedKeys = [self sortAllKeys:NSOrderedDescending];
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tableView reloadData];
    });
#ifdef DEBUG
    NSLog(@"%s: currentPeriodUsageString:%@", __FUNCTION__, digitalLabel.text);
#endif
    [Flurry logEvent:@"Diagnostics"];
    [Flurry logPageView];
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

- (NSArray*)sortAllKeys:(NSComparisonResult)sortDirection
{
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) {
        static NSDateFormatter *formatter = nil;
        if (! formatter) {
            MGDataManager *manager = [MGDataManager sharedInstance];
            formatter = [manager shortTimeFormatter];
        }
        
        NSString *string1 = (NSString *)object1;
        NSString *string2 = (NSString *)object2;
        NSDate *date1 = [formatter dateFromString:string1];
        NSDate *date2 = [formatter dateFromString:string2];
        NSTimeInterval interval1 = [date1 timeIntervalSince1970];
        NSTimeInterval interval2 = [date2 timeIntervalSince1970];
        if (interval1 > interval2) {
            if (sortDirection == NSOrderedDescending) {
                NSComparisonResult result = NSOrderedDescending;
                return result;
            } else {
                NSComparisonResult result = NSOrderedAscending;
                return result;
            }
        }
        if (interval1 < interval2) {
            if (sortDirection == NSOrderedDescending) {
                NSComparisonResult result = NSOrderedAscending;
                return result;
            } else {
                NSComparisonResult result = NSOrderedDescending;
                return result;
            }
        } else {
            NSComparisonResult result = NSOrderedSame;
            return result;
        }
    };
    MGDataManager *manager = [MGDataManager sharedInstance];
    NSArray *array = [manager.bootTimes allKeys];
    SEL sel = @selector(sortedArrayWithOptions:usingComparator:);
    if ([array respondsToSelector:sel]) {
        NSSortOptions options = NSSortConcurrent | NSSortStable;
        NSArray *sorted = [array sortedArrayWithOptions:options
                                        usingComparator:comparator];
        return sorted;
    } else {
        NSArray *sorted = [array sortedArrayUsingComparator:comparator];
        return sorted;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
#ifdef DEBUG
    NSLog(@"%s: sortedKeys:%d", __FUNCTION__, [sortedKeys count]);
#endif
    MGDataManager *manager = [MGDataManager sharedInstance];
    [manager loadCurrentBillPeriod];
    MGCurrentBillPeriod *billPeriod = [manager currentBillPeriod];
    if (billPeriod) {
        return [sortedKeys count] + 1;
    } else {
        return [sortedKeys count];
    }
}

- (UITableViewCell *)handleStatsManager:(UITableView *)aTableView
                  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell*) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor colorWithWhite:1. alpha:0.65]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:.65 alpha:0.7]];
    }
    
    NSString *usageString;
    NSString *headerString;
    MGDataManager *manager = [MGDataManager sharedInstance];
    if (indexPath.row < [sortedKeys count]) {
        NSString *dateString = [sortedKeys objectAtIndex:indexPath.row];
        NSArray *array = [manager.bootTimes objectForKey:dateString];
        
#define BOOT_TIME_SENT_INDEX 0
#define BOOT_TIME_RECEIVED_INDEX 1
        
        NSNumber *sentNumber = [array objectAtIndex:BOOT_TIME_SENT_INDEX];
        NSNumber *receivedNumber = [array objectAtIndex:BOOT_TIME_RECEIVED_INDEX];
        NSDate *realBootTime = [array objectAtIndex:2];
        u_int64_t received = [receivedNumber unsignedLongLongValue];
        u_int64_t sent = [sentNumber unsignedLongLongValue];
        float BytesPerMB = 1024 * 1024;
        float receivedInUnit = received / BytesPerMB;
        float sentInUnit = sent / BytesPerMB;
        
        NSString *sentString = [NSString stringWithFormat:@"%.1f MB s", sentInUnit];
        NSString *receiveString = [NSString stringWithFormat:@"%.1f MB r", receivedInUnit];
        NSString *totalString = [NSString stringWithFormat:@"%.1f MB", receivedInUnit + sentInUnit];
        usageString = [NSString stringWithFormat:@"%@, %@, %@", totalString, receiveString, sentString];
        
        NSString *realBootTimeString = [manager stringFromMediumTimeFormatter:realBootTime];
        headerString = [NSString stringWithFormat:@"Device booted at %@",
                                  realBootTimeString];
    } else {
        const float BytesPerMB = 1024 * 1024.0;
        [manager loadCurrentBillPeriod];
        MGCurrentBillPeriod *billPeriod = [manager currentBillPeriod];
        NSNumber *adjustedDataUsage = [billPeriod adjustedDataUsageInMB];
        float adjustedInUnit = [adjustedDataUsage floatValue];
        double adjustedInBytes = adjustedInUnit * BytesPerMB;
        int64_t adjustedInt64 = adjustedInBytes;
        
        if (adjustedInt64 < 0) {
            NSString *string = [manager readableUsageIn64Unit:adjustedInt64];
            usageString = [NSString stringWithFormat:@"-%@", string];
        } else {
            usageString = [manager readableUsageIn64Unit:adjustedInt64];
        }
        headerString = @"Adjusted Usage";
    }
    
    cell.textLabel.text = usageString;
    cell.detailTextLabel.text = headerString;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self handleStatsManager:aTableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - IBAction

- (IBAction)tappedButtonCancel:(id)sender {
    //        [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    tableView = nil;
    [super viewDidUnload];
}
@end
