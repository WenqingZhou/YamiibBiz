//
//  ViewController.m
//  YawiiB
//
//  Created by wenqing zhou on 10/25/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "ViewController.h"
#import "AccountInfoHandler.h"
#import <QuartzCore/QuartzCore.h>
#import "SystemSetting.h"
#import "NSDate+formatString.h"
#import "UITextField+Validation.h"
#import "NSString+MD5.h"
#import "Utility.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:115.0/255 blue:177.0/255 alpha:1.0]];
    UIImage *imageForGreenBtn=[[UIImage imageNamed:@"greenButton.png"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *imageForGreenBtn_highlighted=[[UIImage imageNamed:@"greenButtonHighlight.png"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [loginBtn setBackgroundImage:imageForGreenBtn_highlighted forState:UIControlStateHighlighted];
    [loginBtn setBackgroundImage:imageForGreenBtn forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:imageForGreenBtn forState:UIControlStateDisabled];
    [loginBtn setTitle:NSLocalizedString(@"login_lbl",@"login_lbl")
              forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    usernameTF.layer.cornerRadius= 8.0f;
    [usernameTF setPlaceholder:NSLocalizedString(@"email_lbl", @"email_lbl")];
    usernameTF.layer.borderColor=[[UIColor lightGrayColor] CGColor];   
    usernameTF.layer.masksToBounds=YES;
    usernameTF.layer.borderWidth=1.0f;
    usernameTF.delegate=self;
    
    passwordTF.layer.cornerRadius= 8.0f;
    [passwordTF setPlaceholder:NSLocalizedString(@"password_lbl", @"password_lbl")];
    passwordTF.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    passwordTF.layer.masksToBounds=YES;
    passwordTF.layer.borderWidth=1.0f;
    passwordTF.delegate=self;
    
    tradeMark.text=[NSString stringWithFormat:@"%@ © %@",[[NSDate date] getYear],APP_COMPANY];
    
    [forgetPasswordBtn setTitle:NSLocalizedString(@"forget_password_lbl", @"forget_password_lbl")
                       forState:UIControlStateNormal];
    
    [sloganLabel setText:NSLocalizedString(@"wake_up_your_customers_lbl", @"wake_up_your_customers_lbl")];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgetPassword:(id)sender
{
    NSString *recipients = [NSString stringWithFormat:@"mailto:admin@yamii.fi?subject=%@",@"Forget my password"];
    
    NSString *body = [NSString stringWithFormat:@"&body=username:%@",usernameTF.text];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)grabURL:(id)sender
{
    if ([usernameTF isValidStringAndFocus:YES] && [passwordTF isValidStringAndFocus:YES]) {
        [usernameTF endEditing:YES];
        [passwordTF endEditing:YES];
        [self recoverUI];
        YawiiServiceHandler *handler=[[YawiiServiceHandler alloc] init];
        handler.delegate=self;
        MBProgressHUD *progressView=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [progressView setMode:MBProgressHUDModeIndeterminate];
        [progressView setAnimationType:MBProgressHUDAnimationFade];
        [progressView setLabelText:NSLocalizedString(@"login_wait_msg", @"login_wait_msg")];
        [progressView showAnimated:YES whileExecutingBlock:^(void) {
            NSString *urlStr=[[URLHandler sharedURLHandler] loginURL];
            NSLog(@"urlStr:%@",urlStr);
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setValue:usernameTF.text forKey:@"email"];
            [dict setValue:[passwordTF.text MD5] forKey:@"pass"];
            [dict setValue:[Utility currentLanguageString] forKey:@"lang"];
            [handler postRequestForUrl:[NSURL URLWithString:urlStr] dict:dict];
            [dict release];
            [handler release];
        }];
    }
    /*
    AddSpecialViewController *asvc;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        asvc = [[AddSpecialViewController alloc] initWithNibName:@"AddSpecialViewController_iPhone" bundle:nil];
    } else
    {
        asvc = [[AddSpecialViewController alloc] initWithNibName:@"AddSpecialViewController_iPad" bundle:nil];
    }
    [self.navigationController pushViewController:asvc animated:YES];
    [asvc release];
     */
     
}

#pragma LoginDelegate methods

- (void)successfulToRequest:(NSDictionary *)response
{
    long long int responseCode=[[response objectForKey:@"code"] longLongValue];
    switch (responseCode) {
        case 200:
        {
            NSMutableDictionary *infoDict=[response objectForKey:@"message"];
            [[AccountInfoHandler sharedAccountHandler] updateInfo:infoDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                AddSpecialViewController *asvc;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    asvc = [[AddSpecialViewController alloc] initWithNibName:@"AddSpecialViewController_iPhone" bundle:nil];
                } else
                {
                    asvc = [[AddSpecialViewController alloc] initWithNibName:@"AddSpecialViewController_iPad" bundle:nil];
                }
                [self.navigationController pushViewController:asvc animated:YES];
                [asvc release];
            });
            break;
        }
        case 500:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *wrongPassAlert= [[UIAlertView alloc] initWithTitle:@"Error" message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil];
                [wrongPassAlert show];
                [wrongPassAlert release];
            });
            NSLog(@"Login error: %@",[response objectForKey:@"message"]);
            break;
        }

        default:
            break;
    }
            
}
- (void)failToRequestWithError:(NSString *)errorStr
{
    UIAlertView *wrongPassAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"login_fail_msg", @"login_fail_msg") delegate:nil cancelButtonTitle:NSLocalizedString(@"Retry", @"Retry") otherButtonTitles:nil];
    [wrongPassAlert show];
    [wrongPassAlert release];
    NSLog(@"error:%@",errorStr);
}

#pragma UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointMake(0, 90) animated:YES];
    [scrollView setScrollEnabled:YES];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    [self recoverUI];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [scrollView setScrollEnabled:NO];
    return YES;
}

#pragma UI

- (void)recoverUI
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


@end
