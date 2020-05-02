//
//  MGAboutController.m
//  Data Robot
//
//  Created by Dan Park on 6/23/13.
//  Copyright (c) 2013 magicpoint.us. All rights reserved.
//

#import "MGAboutController.h"
#import "MGLiveMeterController.h"
#import "Flurry.h"

@interface MGAboutController ()
<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@end

@implementation MGAboutController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [Flurry logEvent:@"About"];
    [Flurry logPageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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

- (IBAction)requestUsageService:(id)sender
{
    //    NSString *address = @"pref://root=general&path=USAGE";
    ////    NSString *address = @"tel://15551212";
    //    NSURL *url = [NSURL URLWithString:address];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    if (! [application canOpenURL:url]) {
    //		NSString *message = @"Device not configured to request the data usage service.";
    //        NSString *title = @"Data Robot";
    //        [self showAlertView:message
    //                  withTitle:title];
    //    } else {
    //        [application openURL:url];
    //    }
}

- (void)showAlertView:(NSString *)message
            withTitle:(NSString*)title
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
	
	[alertView show];
}

- (void)composeSMSMessage:(NSArray*)recipients
              withMessage:(NSString*)message
{
	MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    if (! [MFMessageComposeViewController canSendText]) {
		NSString *message = @"Device not configured to send SMS.";
        NSString *title = @"Data Robot";
        [self showAlertView:message
                  withTitle:title];
    } else {
        vc.messageComposeDelegate = self;
        [vc setRecipients:recipients];
        [vc setBody:message];
        [self presentViewController:vc animated:YES completion:^(){
        }];
    }
}

- (void)composeEmail:(NSArray*)emailAddresses
         withSubject:(NSString*)subject
         withMessage:(NSString*)message
{
	MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    if (! [MFMailComposeViewController canSendMail]) {
		NSString *message = @"Device not configured to send email.";
        NSString *title = @"Data Robot";
        [self showAlertView:message
                  withTitle:title];
    } else {
        vc.mailComposeDelegate = self;
        [vc setToRecipients:emailAddresses];
        [vc setSubject:subject];
        [vc setMessageBody:message isHTML:NO];
        [self presentViewController:vc animated:YES completion:^(){
        }];
    }
}

- (IBAction)openReviewPage:(id)sender
{
//    NSString *templateReviewURL = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
//    NSString *templateReviewURLIpad = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=APP_ID";
//    NSString *address = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&type=Purple+Software", appId];
    
    NSString *appId = @"669803931";
    NSString *address = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&type=Purple+Software", appId];
    NSURL *url = [NSURL URLWithString:address];
    UIApplication *application = [UIApplication sharedApplication];
    if (! [application canOpenURL:url]) {
		NSString *message = @"Device not configured to open App Store App Review.";
        NSString *title = @"Data Robot";
        [self showAlertView:message
                  withTitle:title];
    } else {
        [application openURL:url];
    }
}

- (IBAction)openLiveMeter:(id)sender
{
    MGLiveMeterController *content = [[MGLiveMeterController alloc] initWithNibName:@"MGLiveMeterController" bundle:nil];
    content.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:content
                       animated:YES
                     completion:^{
                     }];
}

- (IBAction)openMaker:(id)sender
{
    NSString *address = @"http://appstore.com/hbholding";
    NSURL *url = [NSURL URLWithString:address];
    UIApplication *application = [UIApplication sharedApplication];
    if (! [application canOpenURL:url]) {
		NSString *message = @"Device not configured to open App Store.";
        NSString *title = @"Data Robot";
        [self showAlertView:message
                  withTitle:title];
    } else {
        [application openURL:url];
    }
}

- (IBAction)emailSupport:(id)sender
{
    NSArray *emailAddress = @[@"support@magicpoint.info"];
	NSString *subject = @"Support for Data Robot";
	NSString *message = [NSString stringWithFormat:@"Hi Tech Support, can you help me with ... ?"];
    
    [self composeEmail:emailAddress
           withSubject:subject
           withMessage:message];
}

- (IBAction)shareByEmail:(id)sender
{
    NSArray *emailAddress = nil;
	NSString *subject = @"Share";
	NSString *message = [NSString stringWithFormat:@"Hi, I want to share this app with you.\n\nhttp://appstore.com/datarobot"];
    
    [self composeEmail:emailAddress
           withSubject:subject
           withMessage:message];
}

- (IBAction)shareBySMS:(id)sender
{
    NSArray *recipients = nil;
	NSString *message = [NSString stringWithFormat:@"Hi, I want to share this app with you.\n\nhttp://appstore.com/datarobot"];
    
    [self composeSMSMessage:recipients
                withMessage:message];
}

- (IBAction)shareAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share By"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Email", @"SMS / TEXT", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
}

- (IBAction)tappedButtonCancel:(id)sender {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^() {
        //        [self.navigationController popViewControllerAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self shareByEmail:nil];
        }
            break;
        case 1:
        {
            [self shareBySMS:nil];
        }
            break;
        default:
            break;
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result) {
		case MFMailComposeResultCancelled:
        {
		}
			break;
		case MFMailComposeResultSaved:
		{
		}
			break;
			
		case MFMailComposeResultSent:
		{
		}
			break;
			
		case MFMailComposeResultFailed:
		{
            NSString *title = @"Data Robot";
			NSString *message = @"Sending email failed.";
			[self showAlertView:message withTitle:title];
		}
			break;
		default:
		{
            NSString *title = @"Data Robot";
			NSString *message = @"Sending email unknown error.";
			[self showAlertView:message withTitle:title];
		}
            break;
	}
    [controller dismissViewControllerAnimated:YES completion:^() {
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
				 didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
	{
		case MessageComposeResultCancelled:
		{
		}
			break;
		case MessageComposeResultSent:
		{
		}
			break;
		case MessageComposeResultFailed:
		{
            NSString *title = @"Data Robot";
			NSString *message = @"Sending SMS failed.";
			[self showAlertView:message withTitle:title];
		}
			break;
		default:
		{
            NSString *title = @"Data Robot";
			NSString *message = @"Sending SMS unknown error.";
			[self showAlertView:message withTitle:title];
		}
            break;
	}
    [controller dismissViewControllerAnimated:YES completion:^() {
    }];
}
@end
