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
//  last update: 10.07.21.
//

#import "OAuthAuthView.h"

#import "Logging.h"


@implementation OAuthAuthView

#pragma mark -
#pragma mark setup sub views and other things

- (void)doSetup
{
	self.dataDetectorTypes = UIDataDetectorTypeNone;
	self.scalesPageToFit = YES;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.multipleTouchEnabled = YES;
	
	//activity indicator
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	CGRect selfBounds = self.bounds;
	indicator.center = CGPointMake(selfBounds.size.width / 2, selfBounds.size.height / 2);
	indicator.hidesWhenStopped = YES;

	//dimmer
	//(to cover whole screen even after the device is rotated)
	CGRect outerBounds = [[UIScreen mainScreen] bounds];
	if(outerBounds.size.width > outerBounds.size.height)
		outerBounds.size.height = outerBounds.size.width;
	else if(outerBounds.size.height > outerBounds.size.width)
		outerBounds.size.width = outerBounds.size.height;
	dimmer = [[UIView alloc] initWithFrame:outerBounds];
	dimmer.backgroundColor = [UIColor blackColor];
	dimmer.alpha = 0.0f;
	
	//add dimmer and indicator
	[self addSubview:dimmer];
	[self addSubview:indicator];
	
	//set delegate
	[self setDelegate:self];
	
	//timeout value
	timeout = DEFAULT_TIMEOUT_INTERVAL;
}

#pragma mark -
#pragma mark initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		// Initialization code
		[self doSetup];
		oauth = nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) 
	{
		// Initialization code
		[self doSetup];
		oauth = nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame 
		oauthProvider:(OAuthProvider*)oauthProvider
{
	if (self = [super initWithFrame:frame]) 
	{
		// Initialization code
		[self doSetup];
		oauth = [oauthProvider retain];
    }
    return self;	
}

- (id)initWithFrame:(CGRect)frame 
		consumerKey:(NSString*)consumerKey 
	 consumerSecret:(NSString*)consumerSecret 
	requestTokenUrl:(NSString*)requestTokenUrl 
	 accessTokenUrl:(NSString*)accessTokenUrl 
	   authorizeUrl:(NSString*)authorizeUrl
{
	if (self = [super initWithFrame:frame]) 
	{
		// Initialization code
		[self doSetup];
		oauth = [[OAuthProvider alloc] initWithConsumerKey:consumerKey 
											consumerSecret:consumerSecret 
										   requestTokenUrl:requestTokenUrl 
											accessTokenUrl:accessTokenUrl 
											  authorizeUrl:authorizeUrl 
										   extraParameters:nil];
    }
    return self;
}

- (void)setOAuthProvider:(OAuthProvider*)provider
{
	if(oauth)
	{
		[oauth release];
		oauth = nil;
	}
	
	oauth = [provider retain];
}

- (void)setOAuthAuthViewDelegate:(id<OAuthAuthViewDelegate>)newDelegate
{
	if(oauthAuthViewdelegate)
	{
		[oauthAuthViewdelegate release];
		oauthAuthViewdelegate = nil;
	}
	
	oauthAuthViewdelegate = [newDelegate retain];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
	if(timeoutInterval > 0.0)
		timeout = timeoutInterval;
}

#pragma mark -
#pragma mark open authorize url

- (void)loadAuthPage
{
	NSString* userAuthUrl = [oauth userAuthUrl];
	
	if(userAuthUrl)
	{
		DebugLog(@"loading auth url: %@", userAuthUrl);

		[self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:userAuthUrl] 
										   cachePolicy:NSURLRequestUseProtocolCachePolicy 
									   timeoutInterval:timeout]];
	}
	else
	{
		DebugLog(@"user auth url is nil");
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"Auth URL is not proper" 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark -
#pragma mark overriden methods

- (void)drawRect:(CGRect)rect {
	// Drawing code
}

- (void)layoutSubviews
{
	//change indicator's location
	CGRect selfBounds = self.bounds;
	indicator.center = CGPointMake(selfBounds.size.width / 2, selfBounds.size.height / 2);
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self setUserInteractionEnabled:NO];
	
	dimmer.alpha = DIMMER_ALPHA_VALUE;
	[indicator startAnimating];
	
	//call delegate function
	[oauthAuthViewdelegate oauthAuthView:self did:OAuthAuthViewDidStartLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{	
	dimmer.alpha = 0.0f;
	[indicator stopAnimating];

	[self setUserInteractionEnabled:YES];
	
	//call delegate function
	[oauthAuthViewdelegate oauthAuthView:self did:OAuthAuthViewDidStopLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{	
	dimmer.alpha = DIMMER_ALPHA_VALUE;
	[indicator stopAnimating];

	[self setUserInteractionEnabled:YES];
	
	//call delegate function
	[oauthAuthViewdelegate oauthAuthView:self did:OAuthAuthViewDidStopWithError];

	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Page Load Error" 
													message:[error localizedFailureReason] 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark etc.

- (NSString*)html
{
	return [self stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].innerHTML"];
}

- (void)dealloc {
	
	[oauthAuthViewdelegate release];
	
	[oauth release];
	[dimmer release];
	[indicator release];

	[super dealloc];
}


@end
