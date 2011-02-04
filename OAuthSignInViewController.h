//
//  OAuthSignInViewController.h
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kGGTwitterLoadingBackgroundImage @"twitter_load.png"

@protocol OAuthSignInViewControllerDelegate
@optional
- (void) authenticatedWithPin:(NSString *) pin;
- (void) authenticationFailed;
- (void) authenticationCanceled;
@end


@interface OAuthSignInViewController:UIViewController <UIWebViewDelegate> {
	
	UIWebView									*_webView;
	UINavigationBar								*_navBar;
	UIImageView									*_backgroundView;
	
	id <OAuthSignInViewControllerDelegate>		_delegate;
	UIView										*_blockerView;
	
	BOOL										_loading, _firstLoad;
}

- (id)initWithDelegate:(id<OAuthSignInViewControllerDelegate>) aDelegate;
- (NSString *) locateAuthPinInWebView: (UIWebView *) webView;
- (void) loadRequest:(NSURLRequest*) request;

//This is a weak reference since we don't retain the delegate.
@property (nonatomic, assign) id <OAuthSignInViewControllerDelegate> delegate;
@end
