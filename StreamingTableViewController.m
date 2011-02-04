//
//  StreamingTableViewController.m
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StreamingTableViewController.h"
#import "CJSONDeserializer.h"

@implementation StreamingTableViewController


#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		streamingTweets = [[NSMutableArray alloc] initWithCapacity:25];
		self.tableView.rowHeight = 60.0;
    }
    return self;
}

#pragma mark streamingDelegate
- (void) consumerDidProcessStatus:(NSString*) statusString{
	NSString *jsonString = statusString;
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
	
	if (dictionary!=nil) {
#ifdef DEBUG 
		NSLog(@"status is %@", [dictionary objectForKey:@"text"]);
#endif
		[streamingTweets insertObject:[dictionary objectForKey:@"text"] atIndex:0];
		
		//This method here is slow
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
												[NSIndexPath indexPathForRow:0 inSection:0],
												nil]		  
							  withRowAnimation:UITableViewRowAnimationNone];
	}
}
#pragma mark streamingDelegate end

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [streamingTweets count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];				
		cell.backgroundColor = [UIColor clearColor];
		cell.textLabel.numberOfLines = 3;
		cell.textLabel.textColor = [UIColor darkGrayColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];			
    }
	
	UIFont *font = [UIFont fontWithName:cell.textLabel.font.familyName size:12.0f];
	CGSize maximumSize = CGSizeMake(300, 100);
    CGSize tweetStringSize = [[streamingTweets objectAtIndex:indexPath.row]
							  sizeWithFont:font 
							  constrainedToSize:maximumSize 
							  lineBreakMode:cell.textLabel.lineBreakMode];	
	
	CGRect frame = CGRectMake(0, 0, 300, tweetStringSize.height);
	cell.textLabel.frame = frame;
	cell.textLabel.font = font;
	cell.textLabel.text = [streamingTweets objectAtIndex:indexPath.row];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[streamingTweets release];
    [super dealloc];
}


@end

