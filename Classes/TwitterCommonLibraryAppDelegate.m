//
//  TwitterCommonLibraryAppDelegate.m
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterCommonLibraryAppDelegate.h"
#import "TwitterEngine.h"
#import "StreamingDelegate.h"
#import "OAuthSignInViewController.h"

#define trackingKeyWord @"track=github"	//TODO: REPLACE ME

@implementation TwitterCommonLibraryAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {        
	NSLog(@"Application launched");
	    
	//Create the view controller
	streamingTableController = [[StreamingTableViewController alloc] initWithStyle:UITableViewStylePlain];	
	StreamingConsumer* consumer = [[StreamingConsumer alloc] init];	
	consumer.delegate = streamingTableController;	
	streamingDelegate = [[StreamingDelegate alloc] initWithConsumer:consumer];	
	[consumer release];

	[self.window addSubview:streamingTableController.view];
    [self.window makeKeyAndVisible];

	TwitterEngine* engine = [TwitterEngine sharedEngineWithDelegate:NULL];
	[engine requestRequestToken:self onSuccess:@selector(onRequestTokenSuccess:withData:) onFail:@selector(onRequestTokenFailed:withData:)];
	
	signInController = [[OAuthSignInViewController alloc] initWithDelegate:self];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark oAuth delegate
- (void) onRequestTokenSuccess:(OAServiceTicket *)ticket withData:(NSData *)data {
	//Set the engine's request token with the data recieved.	
	TwitterEngine* sharedEngine = [TwitterEngine sharedEngine];
	[sharedEngine setRequestToken:ticket withData:data];
	
	//now we can start the sign in process.
	[signInController loadRequest:[sharedEngine authorizeURLRequest]];
	[streamingTableController presentModalViewController:signInController animated:YES];
}

- (void) onRequestTokenFailed:(OAServiceTicket *)ticket withData:(NSData *)data {
	NSLog(@"request token failed");
	
	//TODO: add your own error handling here.
}

- (void) onAccessTokenSuccess:(OAServiceTicket *)ticket withData:(NSData *)data {
#ifdef DEBUG
	NSLog(@"got access token");
#endif
	//Set the engine's request token with the data recieved.	
	TwitterEngine* sharedEngine = [TwitterEngine sharedEngine];
	[sharedEngine setAccessTokenWith:ticket withData:data];	

	[self startStreaming];
}

- (void) onAccessTokenFailed:(OAServiceTicket *)ticket withData:(NSData *)data {
	NSLog(@"Access token failed");
	
	//TODO: add your own error handling here.
}


#pragma mark -
#pragma mark OAuthSignInViewController delegate
- (void) authenticatedWithPin:(NSString*) pin{
#ifdef DEBUG
	NSLog(@"authenticated with pin %@", pin);
#endif
	TwitterEngine *engine = [TwitterEngine sharedEngine];
	engine._pin = pin;
	
	//since we got the pin, we can ask for the access token now.
	[engine requestAccessToken:self onSuccess:@selector(onAccessTokenSuccess:withData:) onFail:@selector(onAccessTokenFailed:)];
	
	[streamingTableController dismissModalViewControllerAnimated:YES];
}
- (void) authenticationFailed{
#ifdef DEBUG
	NSLog(@"authentication failed");
#endif	
	[streamingTableController dismissModalViewControllerAnimated:YES];	
}
- (void) authenticationCanceled{
#ifdef DEBUG
	NSLog(@"authentication canceled");
#endif	
	[streamingTableController dismissModalViewControllerAnimated:YES];		
}

#pragma mark -
#pragma mark streaming
-(void) startStreaming{
	 NSURL* url = [[NSURL alloc] initWithString:@"http://stream.twitter.com/1/statuses/filter.json"];
	 
	TwitterEngine* engine = [TwitterEngine sharedEngine];
	 [engine startStreamingWithDelegate:streamingDelegate withURL:url forTracking:trackingKeyWord];
	 
	 [url release];	
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[signInController release];
	[streamingTableController release];
	[streamingDelegate release];
    [window release];
    [super dealloc];
}


@end
