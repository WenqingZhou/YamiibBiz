//
//  PreviewViewController.m
//  YawiiB
//
//  Created by wenqing zhou on 10/28/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "PreviewViewController.h"
#import "AccountInfoHandler.h"
#import "ConstantStrings.h"
#import "SystemSetting.h"
#import "YawiiServiceHandler.h"
#import "MBProgressHUD.h"
#import "URLHandler.h"
#import "Constant.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

@synthesize _params;

- (PreviewViewController *)initWithParamters:(NSMutableDictionary *)params
{
    self=[super init];
    self._params=[NSMutableDictionary dictionaryWithDictionary:params];
    contentView=[[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 406)];
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 310, 346)];
    sendBtn=[[UIButton alloc] init];
    webView=[[UIWebView alloc] init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc!!",[self class]);
    [webView release],webView=nil;
    self._params=nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scrollView setScrollEnabled:YES];
    _scrollView.layer.cornerRadius = 8;
    _scrollView.layer.masksToBounds = YES;
    [_scrollView setScrollEnabled:NO];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:webView];
    [webView setFrame:CGRectMake(0, 0, 310, 350)];
    [webView setDelegate:self];
    [contentView addSubview:_scrollView];
    [self.view addSubview:contentView];
    
    [sendBtn setTitle:NSLocalizedString(@"send_btn", @"send_btn") forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setFrame:CGRectMake(0, 360, 310, 36)];
    UIImage *imageForGreenBtn=[[UIImage imageNamed:@"greenButton.png"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [sendBtn setBackgroundImage:imageForGreenBtn forState:UIControlStateNormal];
    UIImage *imageForGreenBtn_highlighted=[[UIImage imageNamed:@"greenButtonHighlight.png"]
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [sendBtn setBackgroundImage:imageForGreenBtn_highlighted forState:UIControlStateHighlighted];
    [sendBtn setBackgroundImage:imageForGreenBtn forState:UIControlStateDisabled];
    
    [sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:sendBtn];
    
    MBProgressHUD *progressView=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressView setMode:MBProgressHUDModeIndeterminate];
    [progressView setAnimationType:MBProgressHUDAnimationFade];
    [progressView setLabelText:NSLocalizedString(@"Loading", @"Loading")];
    [progressView show:YES];
    [self showTemplate];
    [_scrollView setContentSize:CGSizeMake(310, webView.scrollView.contentSize.height)];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)send
{
    MBProgressHUD *progressView=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressView setMode:MBProgressHUDModeIndeterminate];
    [progressView setAnimationType:MBProgressHUDAnimationFade];
    [progressView setLabelText:NSLocalizedString(@"sending_msg", @"sending_msg")];
    [progressView showAnimated:YES whileExecutingBlock:^{
        YawiiServiceHandler *handler=[[YawiiServiceHandler alloc] init];
        handler.delegate=self;
        NSString *urlStr=[[[URLHandler sharedURLHandler] newSpecial:_params] retain];
        NSString *timestamp=[NSString stringWithFormat:@"%.0f",[[_params objectForKey:NEWSPECIAL_DICT_VALIDTIME] doubleValue]*1000];
        int max=[[_params objectForKey:NEWSPECIAL_DICT_VALIDNUMBER] intValue];
        if (max== MAX_AMOUNT * AMOUNT_INTERVAL
            ||max== MIN_AMOUNT * AMOUNT_INTERVAL)
        {
            max=0;
        }
        NSString *hid=[[AccountInfoHandler sharedAccountHandler] hid];
        NSString *key=[[AccountInfoHandler sharedAccountHandler] key];
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
                            [_params objectForKey:NEWSPECIAL_DICT_ORIGINAL],@"old_price",
                            [_params objectForKey:NEWSPECIAL_DICT_CURRENT],@"new_price",
                            timestamp,@"end_time",
                            [_params objectForKey:NEWSPECIAL_DICT_CONTENT],@"content",
                            [NSString stringWithFormat:@"%d",max],@"nop",
                            hid,@"hid",
                            key,@"key",
                            nil];
        NSLog(@"urlStr:%@",urlStr);
        [handler postRequestForUrl:[NSURL URLWithString:urlStr] dict:dict];
        [urlStr release];
        [handler release];
    }];
}

- (void)successfulToRequest:(NSDictionary *)response
{
    long long int responseCode=[[response objectForKey:@"code"] longLongValue];
    MBProgressHUD *progressBar=[MBProgressHUD HUDForView:self.view];
    [progressBar setMode:MBProgressHUDModeText];
    switch (responseCode) {
        case 200:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sendBtn setTitle:NSLocalizedString(@"published_btn", @"published_btn") forState:UIControlStateDisabled];
                sendBtn.enabled=NO;
                sendBtn.alpha=0.7;
                [progressBar setLabelText:NSLocalizedString(@"published_btn", @"published_btn")];
            });
            break;
        }
        case 500:
            NSLog(@"Error");
            [progressBar setLabelText:NSLocalizedString(@"send_failure_msg", @"send_failure_msg")];
            break;
        default:
            break;
    }
    [progressBar hide:YES afterDelay:1.0f];
}
- (void)failToRequestWithError:(NSString *)errorStr
{
    MBProgressHUD *progressBar=[MBProgressHUD HUDForView:self.view];
    [progressBar setMode:MBProgressHUDModeText];
    [progressBar setLabelText:NSLocalizedString(@"send_failure_msg", @"send_failure_msg")];
    [progressBar hide:YES afterDelay:1.0f];
    NSLog(@"error:%@",errorStr);
}

- (void)showTemplate
{
    NSString *templatePath=[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSLog(@"templatePath:%@",templatePath);
    NSString *htmlStr=[NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    htmlStr=[self fillTemplate:htmlStr];
    NSURL *baseURL = [[NSBundle mainBundle] resourceURL];
    [webView loadHTMLString:htmlStr baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSString *)fillTemplate:(NSString *)htmlStr
{
    NSDictionary *accountInfo=[[[AccountInfoHandler sharedAccountHandler] _dict] objectForKey:@"merchant"];
    int max=[[_params objectForKey:NEWSPECIAL_DICT_VALIDNUMBER] intValue];
    NSString *remainOfferNumber;
    if (max== MAX_AMOUNT * AMOUNT_INTERVAL
        ||max== MIN_AMOUNT * AMOUNT_INTERVAL)
    {
        remainOfferNumber=@"unlimited";
    }
    else
    {
        remainOfferNumber=[NSString stringWithFormat:@"%d",max];
    }
    NSLog(@"template:%@",[accountInfo objectForKey:ACCOUNT_DICT_URL_LOGO_LOCAL]);
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[special_lbl]" withString:NSLocalizedString(@"special_lbl", @"special_lbl")];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[discount_lbl]" withString:[_params objectForKey:NEWSPECIAL_DICT_DISCOUNT]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[name_lbl]" withString:[accountInfo objectForKey:ACCOUNT_DICT_NAME]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[address_lbl]" withString:[accountInfo objectForKey:ACCOUNT_DICT_ADDRESS]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[zip_city_lbl]"
                                               withString:[NSString stringWithFormat:@"%@ %@",[accountInfo objectForKey:ACCOUNT_DICT_POSTALCODE],[accountInfo objectForKey:ACCOUNT_DICT_CITY]]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[logo_url]" withString:[accountInfo objectForKey:ACCOUNT_DICT_URL_LOGO_LOCAL]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[phone_number_lbl]" withString:[accountInfo objectForKey:ACCOUNT_DICT_PHONE]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[content_customer_html]" withString:@""];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[content_max_numner_html]" withString:[self getContent]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[content_last_lbl]"
                                               withString:NSLocalizedString(@"cannot_combine_lbl", @"cannot_combine_lbl")];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[end_time_lbl]" withString:[self getExpiredTime]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[date_lbl]" withString:[self getDate]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[currency_lbl]" withString:[self getCurrencySymbol]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[price_lbl]" withString:[_params objectForKey:NEWSPECIAL_DICT_CURRENT]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[value_lbl]" withString:[_params objectForKey:NEWSPECIAL_DICT_ORIGINAL]];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"[specials_left_html]"
                                               withString:@""];
    return htmlStr;
}

-(NSString *)getContent
{
    NSString *contentStr=[_params objectForKey:NEWSPECIAL_DICT_CONTENT];
    NSArray *texts=[contentStr componentsSeparatedByString:@";"];
    NSString *newContentStr=@"";
    for (NSString *text in texts)
    {
        newContentStr=[newContentStr stringByAppendingFormat:@"<li>%@</li>",text];
    }
    return newContentStr;
}

- (NSString *)getDate
{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yyyy"];
    NSString *hourStr=[df stringFromDate:
                       [NSDate dateWithTimeIntervalSince1970:[[_params objectForKey:NEWSPECIAL_DICT_VALIDTIME] doubleValue]]];
    [df release];
    return hourStr;
}

- (NSString *)getCurrencySymbol
{
    NSDictionary *accountInfo=[[[AccountInfoHandler sharedAccountHandler] _dict] objectForKey:@"merchant"];
    if ([accountInfo objectForKey:ACCOUNT_DICT_CURRENCYCODE]==@"EUR") {
        return @"€";
    }
    else
    {
        return @"€";
    }
}

- (NSString *)getExpiredTime
{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    NSString *hourStr=[df stringFromDate:
                       [NSDate dateWithTimeIntervalSince1970:[[_params objectForKey:NEWSPECIAL_DICT_VALIDTIME] doubleValue]]];
    [df release];
    return [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"time_until_lbl", @"time_until_lbl"),hourStr];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
