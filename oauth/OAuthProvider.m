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
//  OAuthProvider.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 9. 13.
//
//  last update: 10.08.17.
//
//	(based on OAuth 1.0 revision A)
//

#import "OAuthProvider.h"

#import "HTTPUtil.h"
#import "Logging.h"
#import "NSString+Extension.h"


@implementation OAuthProvider

@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize requestTokenUrl;
@synthesize accessTokenUrl;
@synthesize authorizeUrl;
@synthesize oauthToken;
@synthesize accessToken;
@synthesize authorized;

#pragma mark -
#pragma mark initializer

/**
 * initializer
 * 
 * if the user is already authorized(then, no need to authorize again),
 * extraParameters must have 'oauth_token' & 'oauth_token_secret' key-values in it.
 * 
 * ex:
 * 
 * extraParam = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"oauth_token", @"oauth_token_secret", nil] 
 *                                                 forKeys:[NSArray arrayWithObjects:@"xxxxxx", @"yyyyyy", nil]];
 * 
 */
- (id)initWithConsumerKey:(NSString*)aConsumerKey 
	   consumerSecret:(NSString*)aConsumerSecret 
	  requestTokenUrl:(NSString*)aRequestTokenUrl
	   accessTokenUrl:(NSString*)anAccessTokenUrl
		 authorizeUrl:(NSString*)anAuthorizeUrl
	  extraParameters:(NSMutableDictionary*)extraParameters
{
	if(self = [super init])
	{
		self.consumerKey = aConsumerKey;
		self.consumerSecret = aConsumerSecret;
		self.requestTokenUrl = aRequestTokenUrl;
		self.accessTokenUrl = anAccessTokenUrl;
		self.authorizeUrl = anAuthorizeUrl;
		
		timeout = DEFAULT_TIMEOUT_INTERVAL;	//set default timeout value here
		
		self.oauthToken = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", @"", nil]
													  forKeys:[NSArray arrayWithObjects:@"oauth_token", @"oauth_token_secret", nil]];
		if(extraParameters && [extraParameters objectForKey:@"oauth_token"] && [extraParameters objectForKey:@"oauth_token_secret"])
		{
			self.authorized = true;
			self.accessToken = extraParameters;
		}
		else
		{
			self.authorized = false;
			self.accessToken = nil;
		}

	}
	return self;
}

#pragma mark -
#pragma mark helper functions

/**
 * converts string parameter to NSDictionary (ex: name1=value1&name2=value2&...)
 */
- (NSDictionary*)dictionaryFromStringParam:(NSString*)parameter
{
	if(parameter)
	{
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		NSArray* parameters = [parameter componentsSeparatedByString:@"&"];
		for(NSString* param in parameters)
		{
			NSArray* keyValue = [param componentsSeparatedByString:@"="];
			if([keyValue count] >= 2)
			{
				[dict setValue:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
			}
		}
		return [dict autorelease];
	}
	return nil;
}

/**
 * normalizes given url
 */
- (NSString*)normalizedURLStringFrom:(NSString*)url
{
	if(url)
	{		
		NSMutableString* result = [NSMutableString stringWithString:@""];
		NSURL* uri = [NSURL URLWithString:url];

		[result appendString:[[uri scheme] lowercaseString]];
		[result appendString:@"://"];
		[result appendString:[[uri host] lowercaseString]];
		int port = [[uri port] intValue];
		if(port != 0 && (([[uri scheme] isEqualToString:@"http"] && port != 80) || ([[uri scheme] isEqualToString:@"https"] && port != 433)))
			[result appendFormat:@":%d", port];
		[result appendString:[uri path]];
		
		return result;
	}
	return nil;
}

/**
 * normalizes given request parameters (and additional post parameters)
 */
- (NSString*)normalizedRequestParameterFrom:(NSDictionary*)parameters 
						  getPostParameters:(NSDictionary*)getPostParameters
{
	NSMutableString* result = [NSMutableString stringWithString:@""];
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	if(parameters)
	{
		for(NSString* key in [parameters allKeys])
		{
			[dict setValue:[parameters valueForKey:key] forKey:key];
		}
	}
	if(getPostParameters)
	{
		for(NSString* key in [getPostParameters allKeys])
		{
			[dict setValue:[getPostParameters valueForKey:key] forKey:key];
		}
	}

	if([dict count] > 0)
	{
		NSArray* sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
		for(NSString* key in sortedKeys)
		{
			if([key isEqualToString:@"realm"])
				continue;
			if([result length] > 0)
				[result appendString:@"&"];
			[result appendFormat:@"%@=%@", [key urlencodedValue], [[dict valueForKey:key] urlencodedValue]];
		}
	}
	return result;
}

#pragma mark -
#pragma mark signature-related functions

/**
 * generates signature base string from given method/url/parameters
 */
- (NSString*)generateSignatureBaseStringFromMethod:(NSString*)method 
											   url:(NSString*)url 
										parameters:(NSDictionary*)parameters 
								 getPostParameters:(NSDictionary*)getPostParameters
{
	NSString* normalizedUrl = [self normalizedURLStringFrom:url];
	NSString* normalizedParams = [self normalizedRequestParameterFrom:parameters getPostParameters:getPostParameters];

	return [NSString stringWithFormat:@"%@&%@&%@", method, [normalizedUrl urlencodedValue], [normalizedParams urlencodedValue]];
}

/**
 * generates OAuth signature from given signature base string
 */
- (NSString*)generateOauthSignatureFrom:(NSString*)signatureBaseString
{
	NSString* key = [NSString stringWithFormat:@"%@&%@", [self.consumerSecret urlencodedValue], [[self.oauthToken valueForKey:@"oauth_token_secret"] urlencodedValue]];

	return [signatureBaseString hmacSha1DigestWithKey:key];
}

/**
 * generates access signature from given signature base string
 */
- (NSString*)generateAccessSignatureFrom:(NSString*)signatureBaseString
{
	NSString* key = [NSString stringWithFormat:@"%@&%@", [self.consumerSecret urlencodedValue], [[self.accessToken valueForKey:@"oauth_token_secret"] urlencodedValue]];
	
	return [signatureBaseString hmacSha1DigestWithKey:key];
}

/**
 * generates auth header from given parameters
 */
- (NSString*)generateAuthHeaderFrom:(NSDictionary*)parameters
{
	NSMutableString* result = [NSMutableString stringWithString:@""];
	for(NSString* key in [parameters allKeys])
	{
		if([result length] > 0)
			[result appendString:@","];
		[result appendFormat:@"%@=\"%@\"", [key urlencodedValue], [[parameters valueForKey:key] urlencodedValue]];
	}
	
	return result;
}

#pragma mark -
#pragma mark request functions

/**
 * request OAuth token to the service provider
 */
- (id)requestOauthToken
{
	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, @"HMAC-SHA1", [OAuthProvider timestamp], [OAuthProvider nonce], @"1.0", @"oob", nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", @"oauth_callback", nil]];
									 
	//set signature
	[requestTokenHash setValue:[self generateOauthSignatureFrom:[self generateSignatureBaseStringFromMethod:@"POST" url:self.requestTokenUrl parameters:requestTokenHash getPostParameters:nil]] 
														 forKey:@"oauth_signature"];
											 
	//post with auth header
	NSHTTPURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:self.requestTokenUrl] 
													 parameters:nil 
										 additionalHeaderFields:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]] forKey:@"Authorization"] 
												timeoutInterval:timeout
													   response:&response 
														  error:&error];
	
	if([response statusCode] == 200)
	{
		NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
		return [self dictionaryFromStringParam:[resultString autorelease]];
	}
	else
	{
		NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
		DebugLog(@"auth token request error: %ld (%@)", [response statusCode], resultString);
		[resultString release];
	}

	return nil;
}

/**
 * request access token to the service provider with OAuth verifier (PIN number)
 */
- (id)requestAccessToken:(NSString*)oauthVerifier
{
	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.oauthToken valueForKey:@"oauth_token"], @"HMAC-SHA1", [OAuthProvider timestamp], [OAuthProvider nonce], @"1.0", oauthVerifier, nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", @"oauth_verifier", nil]];
	
	//set signature
	[requestTokenHash setValue:[self generateOauthSignatureFrom:[self generateSignatureBaseStringFromMethod:@"POST" url:accessTokenUrl parameters:requestTokenHash getPostParameters:nil]] 
						forKey:@"oauth_signature"];

	//post with auth header
	NSHTTPURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:self.accessTokenUrl] 
													 parameters:nil 
										 additionalHeaderFields:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]] forKey:@"Authorization"] 
												timeoutInterval:timeout
													   response:&response 
														  error:&error];
	
	if([response statusCode] == 200)
	{
		NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
		return [self dictionaryFromStringParam:[resultString autorelease]];
	}
	else
	{
		NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
		DebugLog(@"access token request error: %ld (%@)", [response statusCode], resultString);
		[resultString release];
	}
	
	return nil;
}

/**
 * get url for the user's authentication on the service provider
 */
- (NSString*)userAuthUrl
{
	//reset oauthToken
	[self.oauthToken setValue:@"" forKey:@"oauth_token"];
	[self.oauthToken setValue:@"" forKey:@"oauth_token_secret"];
	
	self.oauthToken = [self requestOauthToken];
	return [NSString stringWithFormat:@"%@?oauth_token=%@", self.authorizeUrl, [self.oauthToken valueForKey:@"oauth_token"]];
}

#pragma mark -
#pragma mark authorize functions

/**
 * authorize user with OAuth verifier returned from the service provider's auth url
 */
- (bool)authorizeWithOauthVerifier:(NSString*)oauthVerifier
{
	@try 
	{
		NSMutableDictionary* returnedAccessToken = [self requestAccessToken:oauthVerifier];
		if(returnedAccessToken)
		{
			self.accessToken = returnedAccessToken;
			self.authorized = true;
			return true;
		}
		
	}
	@catch (NSException * e)
	{
		DebugLog(@"authorize with oauth verifier failed: %@", [e reason]);
	}
	return false;
}

- (void)authorizeWithAccessToken:(NSMutableDictionary *)newAccessToken
{
	self.accessToken = newAccessToken;
	self.authorized = true;
}

#pragma mark -
#pragma mark HTTP Get/Post functions

/**
 * (after authorization) retrieve protected resources from the service provider using GET method
 */
- (NSDictionary*)get:(NSString*)url 
		  parameters:(NSDictionary*)parameters
{
	if(!self.authorized)
		return nil;

	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.accessToken valueForKey:@"oauth_token"], @"HMAC-SHA1", [OAuthProvider timestamp], [OAuthProvider nonce], @"1.0", nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", nil]];

	//set signature
	[requestTokenHash setValue:[self generateAccessSignatureFrom:[self generateSignatureBaseStringFromMethod:@"GET" url:url parameters:requestTokenHash getPostParameters:parameters]] 
						forKey:@"oauth_signature"];
	
	//get with auth header
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromGetRequestWithURL:[NSURL URLWithString:url] 
													parameters:parameters 
										additionalHeaderFields:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]] forKey:@"Authorization"] 
											   timeoutInterval:timeout
													  response:&response 
														 error:&error];
	
	NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	
	NSArray* values = [NSArray arrayWithObjects:[NSNumber numberWithInt:[httpResponse statusCode]], resultString, nil];
	NSArray* keys = [NSArray arrayWithObjects:kOAUTH_RESPONSE_STATUSCODE, kOAUTH_RESPONSE_RESULT, nil];
	
	if([httpResponse statusCode] != 200)
	{
		DebugLog(@"error: %d\n%@", [httpResponse statusCode], resultString);
	}
	[resultString release];
	
	return [NSDictionary dictionaryWithObjects:values
									   forKeys:keys];
}

/**
 * (after authorization) retrieve protected resources from the service provider using POST method
 */
- (NSDictionary*)post:(NSString*)url 
		   parameters:(NSDictionary*)parameters
{
	if(!self.authorized)
		return nil;

	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.accessToken valueForKey:@"oauth_token"], @"HMAC-SHA1", [OAuthProvider timestamp], [OAuthProvider nonce], @"1.0", nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", nil]];

	//set signature
	[requestTokenHash setValue:[self generateAccessSignatureFrom:[self generateSignatureBaseStringFromMethod:@"POST" url:url parameters:requestTokenHash getPostParameters:parameters]] 
						forKey:@"oauth_signature"];
	
	//build up post parameters
	HTTPParamList* paramList = nil;
	if(parameters)
	{
		paramList = [HTTPParamList paramList];
		for(NSString* key in [parameters allKeys])
		{
			[paramList addPlainParamWithName:key value:[parameters valueForKey:key]];
		}
	}
	
	//get with auth header
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:url] 
													 parameters:paramList 
										 additionalHeaderFields:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]] forKey:@"Authorization"] 
												timeoutInterval:timeout
													   response:&response 
														  error:&error];
	
	NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

	NSArray* values = [NSArray arrayWithObjects:[NSNumber numberWithInt:[httpResponse statusCode]], resultString, nil];
	NSArray* keys = [NSArray arrayWithObjects:kOAUTH_RESPONSE_STATUSCODE, kOAUTH_RESPONSE_RESULT, nil];

	if([httpResponse statusCode] != 200)
	{
		DebugLog(@"error: %d\n%@", [httpResponse statusCode], resultString);
	}
	[resultString release];
	
	return [NSDictionary dictionaryWithObjects:values
									   forKeys:keys];
}


/**
 * (after authorization) retrieve protected resources from the service provider using POST method (when including multipart/form-data)
 */
- (NSDictionary*)postMultipart:(NSString*)url 
					parameters:(HTTPParamList*)parameters
{
	if(!self.authorized)
		return nil;
	
	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.accessToken valueForKey:@"oauth_token"], @"HMAC-SHA1", [OAuthProvider timestamp], [OAuthProvider nonce], @"1.0", nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", nil]];
	
	//set signature
	[requestTokenHash setValue:[self generateAccessSignatureFrom:[self generateSignatureBaseStringFromMethod:@"POST" url:url parameters:requestTokenHash getPostParameters:nil]] 
						forKey:@"oauth_signature"];
	
	//get with auth header
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:url] 
													 parameters:parameters 
										 additionalHeaderFields:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]] forKey:@"Authorization"] 
												timeoutInterval:timeout
													   response:&response 
														  error:&error];
	
	NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	
	NSArray* values = [NSArray arrayWithObjects:[NSNumber numberWithInt:[httpResponse statusCode]], resultString, nil];
	NSArray* keys = [NSArray arrayWithObjects:kOAUTH_RESPONSE_STATUSCODE, kOAUTH_RESPONSE_RESULT, nil];
	
	if([httpResponse statusCode] != 200)
	{
		DebugLog(@"error: %d\n%@", [httpResponse statusCode], resultString);
	}
	[resultString release];
	
	return [NSDictionary dictionaryWithObjects:values
									   forKeys:keys];
}

#pragma mark -
#pragma mark time stamp functions

/**
 * get current timestamp
 * 
 */
+ (NSString*)timestamp
{
	return [NSString stringWithFormat:@"%ld", (unsigned long)[[NSDate date] timeIntervalSince1970]];
}

/**
 * generates nonce value
 * 
 */
+ (NSString*)nonce
{
	srandom(time(NULL));
	return [[NSString stringWithFormat:@"%ld", random()] md5Digest];
}

#pragma mark -
#pragma mark etc.

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
	if(timeoutInterval > 0.0)
		timeout = timeoutInterval;
}

- (NSString*)generateSignatureWithMethod:(NSString*)method 
									 url:(NSString*)url 
							   oauthHash:(NSDictionary*)oauthHash 
{
	return [self generateAccessSignatureFrom:[self generateSignatureBaseStringFromMethod:method 
																					 url:url 
																			  parameters:oauthHash 
																	   getPostParameters:nil]];
}

- (void)dealloc
{
	[consumerKey release];
	[consumerSecret release];
	[requestTokenUrl release];
	[accessTokenUrl release];
	[authorizeUrl release];
	[oauthToken release];
	[accessToken release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"consumerKey = %@", consumerKey];
	[description appendString:@", "];
	[description appendFormat:@"consumerSecret = %@", consumerSecret];
	[description appendString:@", "];
	[description appendFormat:@"requestTokenUrl = %@", requestTokenUrl];
	[description appendString:@", "];
	[description appendFormat:@"accessTokenUrl = %@", accessTokenUrl];
	[description appendString:@", "];
	[description appendFormat:@"authorizeUrl = %@", authorizeUrl];
	[description appendString:@", "];
	[description appendFormat:@"accessToken = %@", accessToken];
	[description appendString:@", "];
	[description appendFormat:@"oauthToken = %@", oauthToken];
	[description appendString:@", "];
	[description appendFormat:@"timeout = %lf", timeout];
	
	[description appendString:@"}"];	
	return description;
}

@end
