//
//  StreamingTableViewController.h
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamingConsumer.h"

@interface StreamingTableViewController : UITableViewController <TwitterStreamingDelegate>{
	
	//This array stores the streaming tweets, once it hits certain limit we'll start to delete from the bottom of the list
	//(first in first out kind of circular que)
	NSMutableArray* streamingTweets;
}

- (void) consumerDidProcessStatus:(NSString*) statusString;

@end
