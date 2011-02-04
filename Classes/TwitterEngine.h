//
//  TwitterEngine.h
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTwitterEngine.h"
#import "OAuthConsumer.h"

#define kRequestURL @"http://twitter.com/oauth/request_token"
#define kAccessURL @"http://twitter.com/oauth/access_token"
#define kAuthorizeURL @"http://twitter.com/oauth/authorize"

#define kOAuthConsumerKey @""	//TODO: Add your consumer key here
#define kOAuthConsumerSecret @""	//TODO: add your consumer secret here.

/*
 The TwitterEngine is a singleton class, it has the following use:
 
 1. Handles OAuth Authentication (Signing in/out)
 2. Sends request and recieve response from Twitter. This is done by leveraging MGTE (MGTwitterEngine)
 3. Manages streaming connections from Twitter. Collect streaming data and send it to the processing queue asynchronously.
	Possibily there could be a few. We have direct reference to the streaming connection because we don't need to have multiple streaming connection that do the samething.
	(compare to the connections in 2).
*/

@interface TwitterEngine : MGTwitterEngine {	
	//This connection is managed by the corresponding startStreamingWithDelegate method
	NSURLConnection* streamingConnection;

	//endpoints of oAuth. The consumerKey, consumerSecrete and accessToken is inherited from the MGTwitterEngine super class.
	NSURL* _requestTokenURL;
	NSURL* _accessTokenURL;
	NSURL* _authorizeURL;	
	
	//request token because there's no request token in MGTE because they use xAuth
	OAToken* _requestToken;
	
	/*
	Refer to the out of band work flow in twitter oAuth. This is neccessary in browserless applications. The pin is the equivalent of an oAuth verifier. The pin is sent
	back with the the request token when the user authorizes the request.
	*/
	NSString	*_pin;
}

+ (TwitterEngine*)sharedEngine;

+ (TwitterEngine*)sharedEngineWithDelegate: (NSObject *) delegate;

//starts the streaming connection to a certain request url, that tracks certain keywords.
- (void) startStreamingWithDelegate:(NSObject*)delegate withURL:(NSURL*)url forTracking:(NSString*)keywords;


#pragma mark oAuth
/* 
 The oAuth work flow is (this flow will be implemented by the login controller, we provide the method that 
 power this flow):
 if user is authorized (isAuthorized)
	request the request token (requestRequestToken)
 
	on receiving the request token 
	get the authorize url request address (need both the request token and authorization url. 
	the request token is used to identify the application. (authorizeURLRequest)
	
	load the authorize url to the user (the controller do this through a webview)
 
	get the oAuth verification pin (the controller finds the pin in the web view and sets it in the engine).
 
	exchange the request token for access token (requestAccessToken)
 
	cache the info
 else
	get the access token from cahced info. 
 */


//Checks for the existence of an access token, if access token exists, return true.
- (BOOL) isAuthorized;

//Generate the URL request using the request token, and the authorize url. A webview can load this
//URL request and present it to the user for login.
- (NSURLRequest *) authorizeURLRequest;

- (void)requestRequestToken:(id)aDelegate onSuccess:(SEL)success onFail:(SEL)fail; 

- (void)requestAccessToken:(id)aDelegate onSuccess:(SEL)success onFail:(SEL)fail;

//Clear the access token from the engine, this is equivalent to login out.
- (void) clearAccessToken;

//call back method on request token success
- (void) setRequestToken: (OAServiceTicket *) ticket withData: (NSData *) data;
- (void) setAccessTokenWith: (OAServiceTicket *) ticket withData: (NSData *) data;
#pragma mark oAuth end

//TODO: we may not need to have these properties, or just make them private. It's easier to manage the retain, release cycle this way.
@property (retain, nonatomic) NSURLConnection* streamingConnection;
@property (retain, nonatomic) NSURL* _requestTokenURL;
@property (retain, nonatomic) NSURL* _accessTokenURL;
@property (retain, nonatomic) NSURL* _authorizeTokenURL;
@property (retain, nonatomic) NSString* _pin;
@property (retain, nonatomic) OAToken* _requestToken;

@end
