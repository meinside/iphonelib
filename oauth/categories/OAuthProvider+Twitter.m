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
//  last update: 10.09.29.
//

#import "OAuthProvider+Twitter.h"

#import "HTTPUtil.h"
#import "XMLParser.h"
#import "Logging.h"


@implementation OAuthProvider (OAuthProviderTwitterExtension)

#pragma mark -
#pragma mark Twitter API functions

- (NSDictionary*)verifyCredentials
{
	if(!self.authorized)
		return nil;

	return [self get:TWITTER_VERIFY_CREDENTIALS_URL parameters:nil];
}

- (NSDictionary*)updateStatus:(NSString*)status
					inReplyTo:(NSString*)statusId
					 latitude:(NSString*)latitude
					longitude:(NSString*)longitude
					  placeId:(NSString*)placeId
			displayCoordinate:(BOOL)displayCoordinate
{
	if(!self.authorized)
		return nil;
	
	if([status length] > TWITTER_MESSAGE_MAX_LENGTH)
	{
		DebugLog(@"status is too long (%d)", [status length]);
		return nil;
	}

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

- (NSDictionary*)isFollowingUser:(NSString*)user
{
	if(!self.authorized)
		return nil;

	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:[accessToken objectForKey:@"screen_name"] forKey:@"user_a"];
	[params setObject:user forKey:@"user_b"];
	
	return [self get:TWITTER_FRIENDSHIP_CHECK_URL parameters:params];
}

- (NSDictionary*)isFollowedByUser:(NSString*)user
{
	if(!self.authorized)
		return nil;
	
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:user forKey:@"user_a"];
	[params setObject:[accessToken objectForKey:@"screen_name"] forKey:@"user_b"];
	
	return [self get:TWITTER_FRIENDSHIP_CHECK_URL parameters:params];
}

- (NSDictionary*)followUserId:(NSString*)userId
{
	if(!self.authorized)
		return nil;
	
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:userId forKey:@"user_id"];
	
	return [self post:TWITTER_FOLLOW_URL parameters:params];
}

- (NSDictionary*)followUser:(NSString*)screenName
{
	if(!self.authorized)
		return nil;
	
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:screenName forKey:@"screen_name"];
	
	return [self post:TWITTER_FOLLOW_URL parameters:params];
}

- (NSDictionary*)unfollowUserId:(NSString*)userId
{
	if(!self.authorized)
		return nil;
	
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:userId forKey:@"user_id"];
	
	return [self post:TWITTER_UNFOLLOW_URL parameters:params];
}

- (NSDictionary*)unfollowUser:(NSString*)screenName
{
	if(!self.authorized)
		return nil;
	
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:screenName forKey:@"screen_name"];
	
	return [self post:TWITTER_UNFOLLOW_URL parameters:params];
}

- (NSDictionary*)sendDirectMessage:(NSString*)message toUserId:(NSString*)userId
{
	if(!self.authorized)
		return nil;
	
	if([message length] > TWITTER_MESSAGE_MAX_LENGTH)
	{
		DebugLog(@"message is too long (%d)", [message length]);
		return nil;
	}
	
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:userId forKey:@"user_id"];
	[params setObject:message forKey:@"text"];
	
	return [self post:TWITTER_DIRECT_MESSAGE_WRITE_URL parameters:params];
}

- (NSDictionary*)sendDirectMessage:(NSString*)message toUser:(NSString*)screenName
{
	if(!self.authorized)
		return nil;
	
	if([message length] > TWITTER_MESSAGE_MAX_LENGTH)
	{
		DebugLog(@"message is too long (%d)", [message length]);
		return nil;
	}

	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:screenName forKey:@"screen_name"];
	[params setObject:message forKey:@"text"];
	
	return [self post:TWITTER_DIRECT_MESSAGE_WRITE_URL parameters:params];
}

//TODO - ...


#pragma mark -
#pragma mark Yfrog API functions

- (NSString*)uploadMediaToYfrogWithDeveloperKey:(NSString*)devKey 
											 media:(NSData*)media 
										  filename:(NSString*)filename
									   contentType:(NSString*)contentType
{
	if(!self.authorized)
		return nil;

	NSString* twitterUrl = @"https://api.twitter.com/1/account/verify_credentials.xml";
	NSString* timestamp = [OAuthProvider timestamp];
	NSString* nonce = [OAuthProvider nonce];

	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.accessToken valueForKey:@"oauth_token"], @"HMAC-SHA1", timestamp, nonce, @"1.0", nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", nil]];	
	[requestTokenHash setValue:[self generateAccessSignatureFrom:[self generateSignatureBaseStringFromMethod:@"GET" 
																										 url:twitterUrl 
																								  parameters:requestTokenHash 
																						   getPostParameters:nil]] 
						forKey:@"oauth_signature"];

	NSString* credentials = [NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]];
	
//	DebugLog(@"X-Verify-Credentials-Authorization: %@", credentials);
	
	NSMutableDictionary* hdrs = [NSMutableDictionary dictionary];
	[hdrs setObject:twitterUrl 
			 forKey:@"X-Auth-Service-Provider"];
	[hdrs setObject:credentials
			 forKey:@"X-Verify-Credentials-Authorization"];

	HTTPParamList* params = [HTTPParamList paramList];
	[params addPlainParamWithName:@"key" value:devKey];
	[params addFileParamWithName:@"media" 
					   fillename:filename 
						 content:media 
					 contentType:contentType];

	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:YFROG_UPLOAD_URL] 
													 parameters:params 
										 additionalHeaderFields:hdrs 
												timeoutInterval:timeout
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

- (NSString*)uploadMediaToTwitpicWithDeveloperKey:(NSString*)devKey 
										  message:(NSString*)message
											media:(NSData*)media 
										 filename:(NSString*)filename
									  contentType:(NSString*)contentType
{
	if(!self.authorized)
		return nil;
	
	NSString* twitterUrl = @"https://api.twitter.com/1/account/verify_credentials.json";
	NSString* timestamp = [OAuthProvider timestamp];
	NSString* nonce = [OAuthProvider nonce];
	
	NSMutableDictionary* requestTokenHash = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.consumerKey, [self.accessToken valueForKey:@"oauth_token"], @"HMAC-SHA1", timestamp, nonce, @"1.0", nil]
																			   forKeys:[NSArray arrayWithObjects:@"oauth_consumer_key", @"oauth_token", @"oauth_signature_method", @"oauth_timestamp", @"oauth_nonce", @"oauth_version", nil]];	
	[requestTokenHash setValue:[self generateAccessSignatureFrom:[self generateSignatureBaseStringFromMethod:@"GET" 
																										 url:twitterUrl 
																								  parameters:requestTokenHash 
																						   getPostParameters:nil]] 
						forKey:@"oauth_signature"];

	NSString* credentials = [NSString stringWithFormat:@"OAuth %@", [self generateAuthHeaderFrom:requestTokenHash]];
	
//	DebugLog(@"X-Verify-Credentials-Authorization: %@", credentials);
	
	NSMutableDictionary* hdrs = [NSMutableDictionary dictionary];
	[hdrs setObject:twitterUrl 
			 forKey:@"X-Auth-Service-Provider"];
	[hdrs setObject:credentials
			 forKey:@"X-Verify-Credentials-Authorization"];
	
	HTTPParamList* params = [HTTPParamList paramList];
	[params addPlainParamWithName:@"key" value:devKey];
	[params addPlainParamWithName:@"message" value:message];
	[params addFileParamWithName:@"media" 
					   fillename:filename 
						 content:media 
					 contentType:contentType];
	
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:TWITPIC_UPLOAD_URL] 
													 parameters:params 
										 additionalHeaderFields:hdrs 
												timeoutInterval:timeout
													   response:&response
														  error:&error];
	
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	NSString* mediaUrl = nil;
	if([httpResponse statusCode] == 200)
	{
		XMLParsedTree* parsedTree = [XMLParser XMLParsedTreeFromData:result];
		if(parsedTree)
		{
			mediaUrl = [parsedTree valueAtPath:@"image/url"];
		}
	}
	return mediaUrl;
}

@end
