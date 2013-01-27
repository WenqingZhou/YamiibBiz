//
//  ViewController.m
//  demo
//
//  Created by wenqing zhou on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddSpecialViewController.h"
#import "PreviewViewController.h"
#import "ConstantStrings.h"
#import "Constant.h"
#import "UITextField+Validation.h"
#import "AccountInfoHandler.h"
#import "AppDelegate.h"

@implementation AddSpecialViewController

@synthesize timestamp;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"2.jpg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.0f/255 green:115.0f/255 blue:177.0f/255 alpha:1]];
    self.title=NSLocalizedString(@"add_special_lbl", @"add_special_lbl");
    [self.navigationController.navigationBar setContentMode:UIViewContentModeScaleAspectFill];
    contentView.layer.cornerRadius = 8;
    contentView.layer.masksToBounds = YES;
    
    
    [originalPriceTextField setPlaceholder:NSLocalizedString(@"normal_price_lbl", @"normal_price_lbl")];
    originalPriceTextField.layer.borderWidth=2.0f;
    originalPriceTextField.layer.borderColor=[[UIColor colorWithRed:125.0f/255 green:212.0f/255 blue:248.0f/255 alpha:1.0f] CGColor];
    
    
    [newPriceTextField setPlaceholder:NSLocalizedString(@"special_price_lbl", @"special_price_lbl")];
    newPriceTextField.layer.borderWidth=2.0f;
    newPriceTextField.layer.borderColor=[[UIColor colorWithRed:125.0f/255 green:212.0f/255 blue:248.0f/255 alpha:1.0f] CGColor];
    
    [self updatePercentForOriginalPrice:0.0f newValue:0.0f];
    
    timeSlider.maximumValue=MAX_DURATION;
    timeSlider.minimumValue=MIN_DURATION;
    timeSlider.value=(timeSlider.maximumValue - timeSlider.minimumValue)/2;
    [timeSlider setMinimumTrackTintColor:[UIColor colorWithRed:0.0f/255 green:115.0f/255 blue:177.0f/255 alpha:1]];
    amountSlider.maximumValue=MAX_AMOUNT;
    amountSlider.minimumValue=MIN_AMOUNT;
    amountSlider.value=(amountSlider.maximumValue - amountSlider.minimumValue)/2;
    [amountSlider setMinimumTrackTintColor:[UIColor colorWithRed:0.0f/255 green:115.0f/255 blue:177.0f/255 alpha:1]];
    
    [timeSlider addTarget:self action:@selector(timeChanged) forControlEvents:UIControlEventValueChanged];
    [timeSlider addTarget:self action:@selector(timeChangeFinished) forControlEvents:UIControlEventTouchUpInside];
    [amountSlider addTarget:self action:@selector(amountChanged) forControlEvents:UIControlEventValueChanged];
    [amountSlider addTarget:self action:@selector(amountChangeFinished) forControlEvents:UIControlEventTouchUpInside];
    
    [self timeChanged];
    [self amountChanged];
    
    
    [commentView setEditable:YES];
    commentView.layer.borderWidth=2.0f;
    commentView.layer.borderColor=[[UIColor colorWithRed:125.0f/255 green:212.0f/255 blue:248.0f/255 alpha:1.0f] CGColor];
    [commentView setPlaceholder:NSLocalizedString(@"content_hint_lbl", @"content_hint_lbl")];
    [commentView setPlaceholderTextColor:[UIColor lightGrayColor]];
    [scrollView setScrollEnabled:YES];
    [scrollView setDelegate:self];
    [scrollView setContentSize:CGSizeMake(320, 650)];
    
    [previewBtn setTitle:NSLocalizedString(@"preview_lbl", @"preview_lbl") forState:UIControlStateNormal];
    [previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *imageForGreenBtn=[[UIImage imageNamed:@"greenButton.png"] 
                 resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [previewBtn setBackgroundImage:imageForGreenBtn forState:UIControlStateNormal];
    [previewBtn setBackgroundImage:imageForGreenBtn forState:UIControlStateDisabled];
    UIImage *imageForGreenBtn_highlighted=[[UIImage imageNamed:@"greenButtonHighlight.png"]
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [previewBtn setBackgroundImage:imageForGreenBtn_highlighted forState:UIControlStateHighlighted];
    [previewBtn addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    
    
    [originalPriceTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [newPriceTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    commentView.delegate=self;
    originalPriceTextField.delegate=self;
    newPriceTextField.delegate=self;
    
    UIBarButtonItem *settingBtnItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"logout_lbl",@"logout_lbl") style:UIBarButtonItemStylePlain target:self action:@selector(showLogoutMenu)];
    self.navigationItem.rightBarButtonItem=settingBtnItem;
    [settingBtnItem release];
    
    [self.navigationItem setHidesBackButton:YES];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)preview
{
    if ([self validateForm]) {
        PreviewViewController *pvc=[[PreviewViewController alloc] initWithParamters:[self getParameters]];
        [self.navigationController pushViewController:pvc animated:YES];
        [pvc release];
    }
}

- (NSMutableDictionary *)getParameters
{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setObject:commentView.text forKey:NEWSPECIAL_DICT_CONTENT];
    [parameters setObject:newPriceTextField.text forKey:NEWSPECIAL_DICT_CURRENT];
    [parameters setObject:originalPriceTextField.text forKey:NEWSPECIAL_DICT_ORIGINAL];
    [parameters setObject:[self getAmount] forKey:NEWSPECIAL_DICT_VALIDNUMBER];
    [parameters setObject:[NSNumber numberWithDouble:self.timestamp] forKey:NEWSPECIAL_DICT_VALIDTIME];
    [parameters setObject:percentLabel.text forKey:NEWSPECIAL_DICT_DISCOUNT];
    return [parameters autorelease];
}

- (void)timeChanged
{
    NSTimeInterval value=round(timeSlider.value);
    int64_t currentTimestamp=round([[NSDate date] timeIntervalSince1970]);
    int durationInterval=DURATION_INTERVAL;
    if (currentTimestamp % durationInterval <= durationInterval/2)
    {
        currentTimestamp=currentTimestamp + 2*durationInterval - currentTimestamp % durationInterval;
    }
    else
    {
        currentTimestamp=currentTimestamp + 3*durationInterval - currentTimestamp % durationInterval;
    }
    currentTimestamp+=value * durationInterval;
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    NSString *hourStr=[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:currentTimestamp]];
    [df release];
    self.timestamp=currentTimestamp;
    [timeLabel setText:[NSString stringWithFormat:@"%@\t%@",NSLocalizedString(@"time_until_lbl", @"time_until_lbl"),hourStr]];
}

- (NSString *)getAmount
{
    int amount=round(amountSlider.value) * AMOUNT_INTERVAL;
    NSLog(@"amout:%d",amount);
    return [NSString stringWithFormat:@"%d",amount];
}

- (BOOL)validateForm
{
    return ([commentView isValidStringAndFocus:YES]||[self alertForInvalidComment])
         &&[originalPriceTextField isValidStringAndFocus:YES]
         &&[newPriceTextField isValidStringAndFocus:YES]
         &&[self validateDiscount];
}

- (BOOL)alertForInvalidComment
{
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"no_special_content_msg", @"no_special_content_msg") delegate:nil cancelButtonTitle:NSLocalizedString(@"Enter", @"Enter") otherButtonTitles:nil];
    [alert show];
    [alert release];
    return NO;
}

-(bool)validateDiscount
{
    if([percentLabel isValidStringAndFocus:NO] &&
       [[percentLabel.text stringByReplacingOccurrencesOfString:@"-" withString:@""] intValue] >= MIN_DISCOUNT_PERCENT) {
        return YES;
    }
    else
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"discount_smaller_msg", @"discount_smaller_msg") delegate:nil cancelButtonTitle:NSLocalizedString(@"Modify", @"Modify") otherButtonTitles:nil];
        [alert show];
        [alert release];
        [newPriceTextField becomeFirstResponder];
        return NO;
    }
}
- (void)timeChangeFinished
{
    NSTimeInterval value=round(timeSlider.value);
    [timeSlider setValue:value];
}

- (void)amountChangeFinished
{
    NSTimeInterval value=round(amountSlider.value);
    [amountSlider setValue:value];
}

- (void)amountChanged
{
    NSTimeInterval value=round(amountSlider.value);
    int amount=value * AMOUNT_INTERVAL;
    NSString *amountStr;
    if (value==amountSlider.maximumValue||value==amountSlider.minimumValue) {
        amountStr=NSLocalizedString(@"unlimited_lbl", @"unlimited_lbl");
    }
    else
    {
        amountStr=[NSString stringWithFormat:@"%d",amount];
    }
    [amountLabel setText:[NSString stringWithFormat:@"%@\t%@",NSLocalizedString(@"num_of_offers_lbl", @"num_of_offers_lbl"),amountStr]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
    if (numberOfMatches == 0)
    {
        return NO;
    }
    else
    {
        NSString *newString=[textField.text stringByReplacingCharactersInRange:range withString:string];
        if (textField == originalPriceTextField) {
            [self updatePercentForOriginalPrice:[newString doubleValue] newValue:[newPriceTextField.text doubleValue]];
        }
        else if(textField == newPriceTextField)
        {
            [self updatePercentForOriginalPrice:[originalPriceTextField.text doubleValue] newValue:[newString doubleValue]];
        }
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField  
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    /*
    [scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
    */
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    /*
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    */
    return YES;
}

- (void)updatePercentForOriginalPrice:(double)originalPrice newValue:(double)newPrice
{
    double percent=[self getPercentValue:originalPrice newValue:newPrice];
    if (percent!=0.0 && percent!=HUGE_VAL &&percent!=HUGE_VALL && percent!=HUGE_VALF)
    {
        if (percent >= MIN_DISCOUNT_PERCENT) {
            [percentLabel setTextColor:[UIColor grayColor]];
        }
        else
        {
            [percentLabel setTextColor:[UIColor redColor]];
        }
        [percentLabel setText:[NSString stringWithFormat:@"-%.f%%",round(percent)]];
    }
    else
    {
        [percentLabel setText:@""];
    }
    
}

- (double)getPercentValue:(double)orignalValue newValue:(double)newValue
{
    double percent=0.0;
    if (orignalValue != 0.0 && newValue != 0.0 && newValue < orignalValue && orignalValue>0 && newValue >0) {
        percent=(orignalValue-newValue)/orignalValue*100;
    }
    return percent;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
    // allow new line
    /*
    if([text isEqualToString:@"\n"]) 
    {
        [textView resignFirstResponder];
        return NO;
    }
    */
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)showLogoutMenu
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"logout_lbl",@"logout_lbl") otherButtonTitles:nil, nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [self logout];
    }
}

- (void)logout
{
    [[AccountInfoHandler sharedAccountHandler] logout];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] loadFirstView];
    
}
#pragma validation methods




@end
