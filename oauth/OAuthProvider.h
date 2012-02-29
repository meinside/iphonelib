//
//  OAuthProvider.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 9. 13.
//
//  last update: 10.09.29.
//
//	(based on OAuth 1.0 revision A)
//

#pragma once
#import <Foundation/Foundation.h>

#import "HTTPUtil.h"
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
	
	HTTPUtil* httpUtil;
	
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
- (void)asyncGet:(NSString*)url
	  parameters:(NSDictionary*)parameters 
			  to:(id)delegate
		selector:(SEL)selector;	//selector will receive NSDictionary for result as a parameter

/**
 * (after authorization) retrieve protected resources from the service provider using POST method
 * 
 * returns: NSDictionary with keys: kOAUTH_RESPONSE_STATUSCODE(http status code), kOAUTH_RESPONSE_RESULT(result string)
 */
- (NSDictionary*)post:(NSString*)url 
		   parameters:(NSDictionary*)parameters;
- (void)asyncPost:(NSString*)url 
	   parameters:(NSDictionary*)parameters 
			   to:(id)delegate
		 selector:(SEL)selector;	//selector will receive NSDictionary for result as a parameter

/**
 * (after authorization) retrieve protected resources from the service provider using POST method (when including multipart/form-data)
 * 
 * returns: NSDictionary with keys: kOAUTH_RESPONSE_STATUSCODE(http status code), kOAUTH_RESPONSE_RESULT(result string)
 */
- (NSDictionary*)postMultipart:(NSString*)url 
					parameters:(HTTPParamList*)parameters;
- (void)asyncPostMultipart:(NSString*)url 
				parameters:(HTTPParamList*)parameters 
						to:(id)delegate
				  selector:(SEL)selector;	//selector will receive NSDictionary for result as a parameter

+ (NSString*)timestamp;
+ (NSString*)nonce;

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)cancelCurrentConnection;

/**
 * declaration for external use (especially in OAuthProvider extensions)
 */
- (NSString*)generateAuthHeaderFrom:(NSDictionary*)parameters;
- (NSString*)generateAccessSignatureFrom:(NSString*)signatureBaseString;
- (NSString*)generateSignatureBaseStringFromMethod:(NSString*)method 
											   url:(NSString*)url 
										parameters:(NSDictionary*)parameters 
								 getPostParameters:(NSDictionary*)getPostParameters;

@property (copy, nonatomic) NSString* consumerKey;
@property (copy, nonatomic) NSString* consumerSecret;
@property (copy, nonatomic) NSString* requestTokenUrl;
@property (copy, nonatomic) NSString* accessTokenUrl;
@property (copy, nonatomic) NSString* authorizeUrl;
@property (retain, nonatomic) NSMutableDictionary* oauthToken;
@property (retain, nonatomic) NSMutableDictionary* accessToken;
@property (assign, nonatomic) bool authorized;

@end
