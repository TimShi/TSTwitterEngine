//
//  TwitterCommonLibraryAppDelegate.h
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamingDelegate.h"
#import "StreamingConsumer.h"
#import "StreamingTableViewController.h"
#import "OAuthSignInViewController.h"

@interface TwitterCommonLibraryAppDelegate : NSObject <UIApplicationDelegate, OAuthSignInViewControllerDelegate> {
    UIWindow *window;
	
	StreamingDelegate* streamingDelegate;
	
	StreamingTableViewController* streamingTableController;
	
	OAuthSignInViewController* signInController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void) startStreaming;

@end

