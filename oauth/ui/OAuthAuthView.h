/*
 Copyright (c) 2010, Sungjin Han <meinside@gmail.com>
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of meinside nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */
//
//  OAuthAuthView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 1. 9.
//
//  last update: 10.06.27.
//

#import <UIKit/UIKit.h>

#import "OAuthProvider.h"

#define DIMMER_ALPHA_VALUE 0.5f


@protocol OAuthAuthViewDelegate;

@interface OAuthAuthView : UIWebView <UIWebViewDelegate> {

	OAuthProvider* oauth;
	UIView* dimmer;
	UIActivityIndicatorView* indicator;
	
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

- (void)loadAuthPage;

- (NSString*)html;

- (void)setOAuthProvider:(OAuthProvider*)provider;

- (void)setOAuthAuthViewDelegate:(id<OAuthAuthViewDelegate>)newDelegate;

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
