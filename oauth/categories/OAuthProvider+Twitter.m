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
//  OAuthHelper+Twitter.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 1. 10.
//
//  last update: 10.07.21.
//

#import "OAuthProvider+Twitter.h"

#import "HTTPUtil.h"
#import "XMLParser.h"
#import "Logging.h"


@implementation OAuthProvider (OAuthProviderTwitterExtension)

#pragma mark -
#pragma mark Twitter API functions

- (NSDictionary*)updateStatus:(NSString*)status
					inReplyTo:(NSString*)statusId
					 latitude:(NSString*)latitude
					longitude:(NSString*)longitude
					  placeId:(NSString*)placeId
			displayCoordinate:(BOOL)displayCoordinate
{
	if(!self.authorized)
		return NO;

	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	if(status)
		[params setObject:status forKey:@"status"];
	if(latitude)
		[params setObject:latitude forKey:@"lat"];
	if(longitude)
		[params setObject:longitude forKey:@"long"];
	if(placeId)
		[params setObject:placeId forKey:@"place_id"];
	if(!displayCoordinate)
		[params setObject:@"false" forKey:@"display_coordinates"];

	return [self post:TWITTER_STATUSES_UPDATE_URL parameters:params];
}

//TODO - ...


#pragma mark -
#pragma mark Yfrog API functions

- (NSString*)verifyURLForYfrog
{
	if(!self.authorized)
		return nil;
	
	//ex: https://twitter.com/account/verify_credentials.xml?oauth_version=1.0&oauth_nonce=NONCE&oauth_timestamp=STAMP&oauth_consumer_key=CONSUMER_KEY&oauth_token=TOKEN&oauth_signature_method=HMAC-SHA1&oauth_signature=SIGNATURE
	NSString* twitterUrl = @"https://twitter.com/account/verify_credentials.xml";
	NSString* timestamp = [OAuthProvider timestamp];
	NSString* nonce = [OAuthProvider nonce];
	NSDictionary* requestTokenHash = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.accessToken valueForKey:@"oauth_token"], @"HMAC-SHA1", timestamp, nonce, @"1.0", nil]
																 forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", nil]];
	
	NSString* url = [NSString stringWithFormat:@"%@?oauth_version=1.0&oauth_nonce=%@&oauth_timestamp=%@&oauth_consumer_key=%@&oauth_token=%@&oauth_signature_method=HMAC-SHA1&oauth_signature=%@",
					 twitterUrl,
					 nonce,
					 timestamp,
					 self.consumerKey,
					 [self.accessToken valueForKey:@"oauth_token"],
					 [self generateSignatureWithMethod:@"GET" 
												   url:twitterUrl 
											 oauthHash:requestTokenHash]];
	return url;
}

- (NSString*)uploadMediaToYfrogWithDeveloperKey:(NSString*)devKey
									   username:(NSString*)username 
										  media:(NSData*)media 
									   filename:(NSString*)filename 
									contentType:(NSString*)contentType 
									geoTagOrNot:(BOOL)geoTagOrNot 
									publicOrNot:(BOOL)publicOrNot
{
	if(!self.authorized)
		return nil;

	HTTPParamList* params = [HTTPParamList paramList];
	[params addPlainParamWithName:@"auth" value:@"oauth"];
	[params addPlainParamWithName:@"username" value:username];
	[params addPlainParamWithName:@"verify_url" value:[self verifyURLForYfrog]];
	if(publicOrNot)
		[params addPlainParamWithName:@"public" value:@"yes"];
	else
		[params addPlainParamWithName:@"public" value:@"no"];
	if(geoTagOrNot)
	{
		[params addPlainParamWithName:@"tags" value:@""];
	}
	[params addPlainParamWithName:@"key" value:devKey];
	[params addFileParamWithName:@"media" fillename:filename content:media contentType:contentType];
	
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:YFROG_UPLOAD_URL] 
													 parameters:params 
										 additionalHeaderFields:nil 
												timeoutInterval:0.0
													   response:&response
														  error:&error];
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	NSString* mediaUrl = nil;
	if([httpResponse statusCode] == 200)
	{
		XMLParsedTree* parsedTree = [XMLParser XMLParsedTreeFromData:result];
		if(parsedTree)
		{
			NSString* stat = [[parsedTree attributesAtPath:@"rsp"] objectForKey:@"stat"];
			if(stat && [stat compare:@"ok"] == NSOrderedSame)
			{
				mediaUrl = [parsedTree valueAtPath:@"rsp/mediaurl"];
			}
			else
			{
				DebugLog(@"error: (%@) %@", [[parsedTree attributesAtPath:@"rsp/err"] objectForKey:@"code"], [[parsedTree attributesAtPath:@"rsp/err"] objectForKey:@"msg"]);
			}
			
		}
	}
	
	return mediaUrl;
}

- (NSString*)uploadMediaToYfrogWithDeveloperKey:(NSString*)devKey
									   username:(NSString*)username 
											url:(NSString*)url 
									geoTagOrNot:(BOOL)geoTagOrNot 
									publicOrNot:(BOOL)publicOrNot
{
	if(!self.authorized)
		return nil;

	HTTPParamList* params = [HTTPParamList paramList];
	[params addPlainParamWithName:@"auth" value:@"oauth"];
	[params addPlainParamWithName:@"username" value:username];
	[params addPlainParamWithName:@"verify_url" value:[self verifyURLForYfrog]];
	if(publicOrNot)
		[params addPlainParamWithName:@"public" value:@"yes"];
	else
		[params addPlainParamWithName:@"public" value:@"no"];
	if(geoTagOrNot)
	{
		[params addPlainParamWithName:@"tags" value:@""];
	}
	[params addPlainParamWithName:@"key" value:devKey];
	[params addPlainParamWithName:@"url" value:url];
	
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:YFROG_UPLOAD_URL] 
													 parameters:params 
										 additionalHeaderFields:nil 
												timeoutInterval:0.0
													   response:&response
														  error:&error];
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	NSString* mediaUrl = nil;
	if([httpResponse statusCode] == 200)
	{
		XMLParsedTree* parsedTree = [XMLParser XMLParsedTreeFromData:result];
		if(parsedTree)
		{
			NSString* stat = [[parsedTree attributesAtPath:@"rsp"] objectForKey:@"stat"];
			if(stat && [stat compare:@"ok"] == NSOrderedSame)
			{
				mediaUrl = [parsedTree valueAtPath:@"rsp/mediaurl"];
			}
			else
			{
				DebugLog(@"error: (%@) %@", [[parsedTree attributesAtPath:@"rsp/err"] objectForKey:@"code"], [[parsedTree attributesAtPath:@"rsp/err"] objectForKey:@"msg"]);
			}

		}
	}
	return mediaUrl;
}

@end
