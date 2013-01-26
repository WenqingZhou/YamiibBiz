//
//  SettingViewController.m
//  YawiiB
//
//  Created by wenqing zhou on 11/4/12.
//  Copyright (c) 2012 Yawii. All rights reserved.
//

#import "SettingViewController.h"
#import "Utility.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.objkeyMappings=[NSArray arrayWithObjects:
                             @"general",//0
                             nil];
        self.keyParametersMappings=[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArray arrayWithObjects:@"Version",@"Language",nil],@"general",
                                    nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:nil];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.914 alpha:1.000]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.objkeyMappings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return [[self.keyParametersMappings objectForKey:[self.objkeyMappings objectAtIndex:section]] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = nil;
    
    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, 150, 30)];
		name.text=NSLocalizedString([[self.keyParametersMappings objectForKey:[self.objkeyMappings objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]
									,[[self.keyParametersMappings objectForKey:[self.objkeyMappings objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]);
		[name setFont:[UIFont boldSystemFontOfSize:16]];
        [name setTextColor:[UIColor darkGrayColor]];
		[name setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:name];
		[name release];
		
		NSString *valueString=[[self.keyParametersMappings objectForKey:[self.objkeyMappings objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
		if ([valueString isEqualToString:@"Version"])
        {
			UILabel *value=[[UILabel alloc] initWithFrame:CGRectMake(180, 5, 120, 30)];
			value.text=[Utility getVersionString];
			[value setFont:[UIFont systemFontOfSize:16]];
			[value setTextColor:[UIColor grayColor]];
			[value setTextAlignment:UITextAlignmentRight];
			[value setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin];
            [value setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:value];
			[value release];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle=UITableViewCellSelectionStyleBlue;

		}
		
		else if([valueString isEqualToString:@"Language"])
		{
			UILabel *value=[[UILabel alloc] initWithFrame:CGRectMake(180, 5, 120, 30)];
			value.text=[Utility currentLanguageString];
			[value setFont:[UIFont systemFontOfSize:16]];
			[value setTextColor:[UIColor grayColor]];
			[value setTextAlignment:UITextAlignmentRight];
			[value setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin];
            [value setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:value];
			[value release];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
		}
    }
    
    // Configure the cell...
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
