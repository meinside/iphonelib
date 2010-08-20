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
//  OAuthProvider.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 9. 13.
//
//  last update: 10.08.20.
//
//	(based on OAuth 1.0 revision A)
//

#pragma once
#import <Foundation/Foundation.h>

#import "HTTPParamList.h"


#define kOAUTH_RESPONSE_STATUSCODE @"statusCode"
#define kOAUTH_RESPONSE_RESULT @"result"

#define DEFAULT_TIMEOUT_INTERVAL 10.0	//long timeout value for slow cellular network


@interface OAuthProvider : NSObject {
	
@private
	NSString* consumerKey;
	NSString* consumerSecret;
	
	NSString* requestTokenUrl;
	NSString* accessTokenUrl;
	NSString* authorizeUrl;
	
	NSMutableDictionary* accessToken;
	NSMutableDictionary* oauthToken;
	
	NSTimeInterval timeout;
	
@public
	bool authorized;
}

/**
 * initializer
 * 
 * if the user is already authorized(then, no need to authorize again),
 * extraParameters must have 'oauth_token' & 'oauth_token_secret' key-values in it.
 * 
 * ex:
 * 
 * extraParam = [NSDictionary 
 *     dictionaryWithObjects:[NSArray arrayWithObjects:@"oauth_token", @"oauth_token_secret", nil] 
 *                   forKeys:[NSArray arrayWithObjects:@"xxxxxx", @"yyyyyy", nil]];
 * 
 */
- (id)initWithConsumerKey:(NSString*)consumerKey 
	   consumerSecret:(NSString*)consumerSecret 
	  requestTokenUrl:(NSString*)requestTokenUrl
	   accessTokenUrl:(NSString*)accessTokenUrl
		 authorizeUrl:(NSString*)authorizeUrl
	  extraParameters:(NSMutableDictionary*)extraParameters;

/**
 * get url for the user's authentication on the service provider
 */
- (NSString*)userAuthUrl;

/**
 * generate signature from given method, url, and oauth header parameters
 * (for OAuthHelper extensions)
 */
- (NSString*)generateSignatureWithMethod:(NSString*)method 
									 url:(NSString*)url 
							   oauthHash:(NSDictionary*)oauthHash;

/**
 * authorize user with OAuth verifier returned from the service provider's auth url
 */
- (bool)authorizeWithOauthVerifier:(NSString*)oauthVerifier;

/**
 * for setting access token(from keychain or something) manually
 */
- (void)authorizeWithAccessToken:(NSMutableDictionary *)newAccessToken;

/**
 * (after authorization) retrieve protected resources from the service provider using GET method
 * 
 * returns: NSDictionary with keys: kOAUTH_RESPONSE_STATUSCODE(http status code), kOAUTH_RESPONSE_RESULT(result string)
 */
- (NSDictionary*)get:(NSString*)url 
		  parameters:(NSDictionary*)parameters;

/**
 * (after authorization) retrieve protected resources from the service provider using POST method
 * 
 * returns: NSDictionary with keys: kOAUTH_RESPONSE_STATUSCODE(http status code), kOAUTH_RESPONSE_RESULT(result string)
 */
- (NSDictionary*)post:(NSString*)url 
		   parameters:(NSDictionary*)parameters;

/**
 * (after authorization) retrieve protected resources from the service provider using POST method (when including multipart/form-data)
 * 
 * returns: NSDictionary with keys: kOAUTH_RESPONSE_STATUSCODE(http status code), kOAUTH_RESPONSE_RESULT(result string)
 */
- (NSDictionary*)postMultipart:(NSString*)url 
					parameters:(HTTPParamList*)parameters;

+ (NSString*)timestamp;
+ (NSString*)nonce;

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

@property (copy, nonatomic) NSString* consumerKey;
@property (copy, nonatomic) NSString* consumerSecret;
@property (copy, nonatomic) NSString* requestTokenUrl;
@property (copy, nonatomic) NSString* accessTokenUrl;
@property (copy, nonatomic) NSString* authorizeUrl;
@property (retain, nonatomic) NSMutableDictionary* oauthToken;
@property (retain, nonatomic) NSMutableDictionary* accessToken;
@property (assign, nonatomic) bool authorized;

@end
