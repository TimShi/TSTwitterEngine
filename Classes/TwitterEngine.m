//
//  TwitterEngine.m
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterEngine.h"
#import "StreamingDelegate.h"

	
static TwitterEngine *sharedEngine = nil;

@implementation TwitterEngine
@synthesize _pin, _requestTokenURL, _accessTokenURL, _authorizeTokenURL, streamingConnection, _requestToken;
- (TwitterEngine *) initOAuthWithDelegate: (NSObject *) delegate {
	//here we call the super class which is MGTE's initWithDelegate method, this delegate handles the REST api call.
    if (self = (id) [super initWithDelegate: delegate]) {
		self._requestTokenURL = [NSURL URLWithString:kRequestURL];
		self._accessTokenURL = [NSURL URLWithString:kAccessURL];
		self._authorizeTokenURL = [NSURL URLWithString:kAuthorizeURL];
	}
    return self;
}

#pragma mark oAuth
- (BOOL) isAuthorized{
	//accessToken is inherited from the super class
	if ([self accessToken].key && [self accessToken].secret){
		return YES;
	}else{
		return NO;
	}
}

- (NSURLRequest *) authorizeURLRequest{
	if (!_requestToken || !_requestToken.key || !_requestToken.secret){
		[NSException raise:NSGenericException format:@"invalid request token"];
	}
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] 
									initWithURL: self._authorizeTokenURL consumer: nil token: _requestToken realm: nil signatureProvider: nil]; 
									
	[request setParameters: [NSArray arrayWithObject: [[[OARequestParameter alloc] initWithName: @"oauth_token" value: _requestToken.key] autorelease]]];	

	[request autorelease];
	return request;
}

- (void)requestRequestToken:(id)aDelegate onSuccess:(SEL)success onFail:(SEL)fail{
	NSLog(@"requesting request token");
	OAConsumer* consumer = [[[OAConsumer alloc] initWithKey:[self consumerKey] secret:[self consumerSecret]] autorelease];
	OAMutableURLRequest	*request = [[[OAMutableURLRequest alloc]
									 initWithURL:self._requestTokenURL
									 consumer:consumer token:nil realm:nil signatureProvider: nil] autorelease];

    [request setHTTPMethod: @"POST"];

	NSLog(@"fetching request token");
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request delegate:aDelegate didFinishSelector:success didFailSelector:fail];
}

- (void)requestAccessToken:(id)aDelegate onSuccess:(SEL)success onFail:(SEL)fail{	
	self._requestToken.verifier = self._pin;
	
	OAConsumer* consumer = [[[OAConsumer alloc] initWithKey:[self consumerKey] secret:[self consumerSecret]] autorelease];
	OAMutableURLRequest	*request = [[[OAMutableURLRequest alloc]
									 initWithURL:self._accessTokenURL
									 consumer:consumer token:self._requestToken realm:nil signatureProvider: nil] autorelease];
	
    [request setHTTPMethod: @"POST"];
	
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request delegate:aDelegate didFinishSelector:success didFailSelector:fail];
	
}

//A call back method when the request is successful
- (void) setRequestToken: (OAServiceTicket *) ticket withData: (NSData *) data {
	if (!ticket.didSucceed || !data){
		return;
	}
	
	NSString *dataString = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];

	if (!dataString){
		return;
	}
	
	[_requestToken release];
	_requestToken = [[OAToken alloc] initWithHTTPResponseBody:dataString];
		
	NSLog(@"request token set");
}

//A call back method when request is successful
- (void) setAccessTokenWith: (OAServiceTicket *) ticket withData: (NSData *) data {
	if (!ticket.didSucceed || !data) {
		return;
	}
		
	NSString *dataString = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	
	if (!dataString){
		return;
	}
	
	//TODO: is this neccessary? why would the data string doesn't have oauth_verifier?
	if (self._pin.length && [dataString rangeOfString: @"oauth_verifier"].location == NSNotFound){ 
		dataString = [dataString stringByAppendingFormat: @"&oauth_verifier=%@", self._pin];
	}
	
	//assign the new access token;
	[self setAccessToken:[[[OAToken alloc] initWithHTTPResponseBody:dataString] autorelease]];
}

//Clear the access token from the engine, this is equivalent to login out.
- (void) clearAccessToken{
	[self setAccessToken:nil];
	[_requestToken release];
	_requestToken = nil;
	self._pin = nil;
}
#pragma mark oAuth End

#pragma mark singleton
+ (TwitterEngine*)sharedEngineWithDelegate: (NSObject *) delegate {
    if (sharedEngine == nil) {
		//alloc calls allocWithZone with the default zone, because we have overriden our own allocWithZone method to force singleton,
		//therefore we call the [super allocWithZone] instead.		
        sharedEngine = [[super allocWithZone:NULL] initOAuthWithDelegate: delegate];
		[sharedEngine setConsumerKey:kOAuthConsumerKey secret:kOAuthConsumerSecret];
    }
    return sharedEngine;
}

+ (TwitterEngine*)sharedEngine{
	return [self sharedEngineWithDelegate:NULL];
}

//overrides so that no new instance would be created by accident. because the singleton instance exists through out the application life cycle
//we never increase or decrease its refrence count.
+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedEngine] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}
#pragma mark end singleton


#pragma mark streaming
- (void) startStreamingWithDelegate:(NSObject*)delegate withURL:(NSURL*)url forTracking:(NSString*)keywords{
#ifdef DEBUG 
	NSLog(@"start streaming for keywords: %@ at url %@", keywords, url);	
#endif	

	OAConsumer* consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey secret:kOAuthConsumerSecret];	
	
	OAMutableURLRequest* streamingRequest = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:self.accessToken realm:nil signatureProvider:nil];
	[streamingRequest setHTTPMethod:@"POST"];
	[streamingRequest setHTTPBody:[keywords dataUsingEncoding:NSUTF8StringEncoding]];
	
	[streamingRequest prepare];
	
	self.streamingConnection = [[NSURLConnection alloc] initWithRequest:streamingRequest delegate:delegate startImmediately:YES];
	
	[consumer release];
	[streamingRequest release];
}
#pragma mark end streaming

-(void) dealloc{
	[_requestTokenURL release];
	[_accessTokenURL release];
	[_authorizeTokenURL release];
	[_pin release];
	[streamingConnection release];
	[super dealloc];
}
@end