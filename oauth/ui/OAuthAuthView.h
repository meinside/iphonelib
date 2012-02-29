//
//  OAuthAuthView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 1. 9.
//
//  last update: 10.08.20.
//

#pragma once
#import <UIKit/UIKit.h>

#import "OAuthProvider.h"

#define DIMMER_ALPHA_VALUE 0.5f


@protocol OAuthAuthViewDelegate;

@interface OAuthAuthView : UIWebView <UIWebViewDelegate> {

	OAuthProvider* oauth;
	UIView* dimmer;
	UIActivityIndicatorView* indicator;
	
	NSTimeInterval timeout;
	
	id<OAuthAuthViewDelegate> oauthAuthViewdelegate;
}

- (id)initWithFrame:(CGRect)frame 
		oauthProvider:(OAuthProvider*)oauthProvider;

- (id)initWithFrame:(CGRect)frame 
		consumerKey:(NSString*)consumerKey 
	 consumerSecret:(NSString*)consumerSecret 
	requestTokenUrl:(NSString*)requestTokenUrl 
	 accessTokenUrl:(NSString*)accessTokenUrl 
	   authorizeUrl:(NSString*)authorizeUrl;

- (BOOL)loadAuthPage;

- (NSString*)html;

- (void)setOAuthProvider:(OAuthProvider*)provider;

- (void)setOAuthAuthViewDelegate:(id<OAuthAuthViewDelegate>)newDelegate;

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

@end


/**
 * OAuthAuthView's delegate
 */
@protocol OAuthAuthViewDelegate<NSObject>

typedef enum _OAuthAuthViewAction {
	OAuthAuthViewDidStartLoading,
	OAuthAuthViewDidStopLoading,
	OAuthAuthViewDidStopWithError,
} OAuthAuthViewAction;

/**
 * called when the WebView did something
 * 
 */
- (void)oauthAuthView:(OAuthAuthView*)view did:(OAuthAuthViewAction)what;

@end
