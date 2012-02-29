//
//  OAuthHelper+Twitter.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 1. 10.
//
//  last update: 10.10.14.
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
	if(statusId)
		[params setObject:statusId forKey:@"in_reply_to_status_id"];
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

- (NSDictionary*)retweetStatusId:(NSString*)statusId
{
	if(!self.authorized)
		return nil;

	return [self post:[NSString stringWithFormat:TWITTER_STATUSES_RETWEET_URL, statusId] parameters:nil];
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

- (void)asyncUploadMediaToYfrogWithDeveloperKey:(NSString*)devKey 
										  media:(NSData*)media 
									   filename:(NSString*)filename
									contentType:(NSString*)contentType
											 to:(id)delegate
									   selector:(SEL)selector
{
	if(!self.authorized)
		return;
	
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
	
	[self cancelCurrentConnection];

	httpUtil = [[HTTPUtil alloc] init];
	[httpUtil sendAsyncPostRequestWithURL:[NSURL URLWithString:YFROG_UPLOAD_URL] 
							   parameters:params
				   additionalHeaderFields:hdrs
						  timeoutInterval:timeout 
									   to:delegate 
								 selector:selector];
	
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

- (void)asyncUploadMediaToTwitpicWithDeveloperKey:(NSString*)devKey 
										  message:(NSString*)message
											media:(NSData*)media 
										 filename:(NSString*)filename
									  contentType:(NSString*)contentType
											   to:(id)delegate
										 selector:(SEL)selector
{
	if(!self.authorized)
		return;
	
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

	[self cancelCurrentConnection];
	
	httpUtil = [[HTTPUtil alloc] init];
	[httpUtil sendAsyncPostRequestWithURL:[NSURL URLWithString:TWITPIC_UPLOAD_URL] 
							   parameters:params
				   additionalHeaderFields:hdrs
						  timeoutInterval:timeout 
									   to:delegate 
								 selector:selector];
}

- (NSString*)uploadMediaToImglyWithMessage:(NSString*)message
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
	[params addPlainParamWithName:@"message" value:message];
	[params addFileParamWithName:@"media" 
					   fillename:filename 
						 content:media 
					 contentType:contentType];
	
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:IMGLY_UPLOAD_URL] 
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

- (void)asyncUploadMediaToImglyWithMessage:(NSString*)message
									 media:(NSData*)media 
								  filename:(NSString*)filename
							   contentType:(NSString*)contentType
										to:(id)delegate
								  selector:(SEL)selector
{
	if(!self.authorized)
		return;
	
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
	[params addPlainParamWithName:@"message" value:message];
	[params addFileParamWithName:@"media" 
					   fillename:filename 
						 content:media 
					 contentType:contentType];
	
	[self cancelCurrentConnection];
	
	httpUtil = [[HTTPUtil alloc] init];
	[httpUtil sendAsyncPostRequestWithURL:[NSURL URLWithString:IMGLY_UPLOAD_URL] 
							   parameters:params
				   additionalHeaderFields:hdrs
						  timeoutInterval:timeout 
									   to:delegate 
								 selector:selector];
}

- (NSString*)uploadVideoToTwitvidWithMessage:(NSString*)message 
									   title:(NSString*)title 
								 description:(NSString*)description
									   video:(NSData*)video 
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
	
//	DebugLog(@"x_verify_credentials_authorization: %@", credentials);

	HTTPParamList* params = [HTTPParamList paramList];
	[params addPlainParamWithName:@"message" value:message];
	[params addPlainParamWithName:@"title" value:title];
	[params addPlainParamWithName:@"description" value:description];
	[params addFileParamWithName:@"media" 
					   fillename:filename 
						 content:video 
					 contentType:contentType];
	[params addPlainParamWithName:@"x_auth_service_provider" value:twitterUrl];
	[params addPlainParamWithName:@"x_verify_credentials_authorization" value:credentials];
	
	NSURLResponse* response;
	NSError* error;
	NSData* result = [HTTPUtil dataResultFromPostRequestWithURL:[NSURL URLWithString:TWITVID_UPLOAD_URL] 
													 parameters:params 
										 additionalHeaderFields:nil 
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
				mediaUrl = [parsedTree valueAtPath:@"rsp/media_url"];
			}
			else
			{
				DebugLog(@"error: (%@) %@", [[parsedTree attributesAtPath:@"rsp/err"] objectForKey:@"code"], [[parsedTree attributesAtPath:@"rsp/err"] objectForKey:@"msg"]);
			}
		}
	}
	return mediaUrl;
}

- (void)asyncUploadVideoToTwitvidWithMessage:(NSString*)message 
									   title:(NSString*)title 
								 description:(NSString*)description
									   video:(NSData*)video 
									filename:(NSString*)filename
								 contentType:(NSString*)contentType
										  to:(id)delegate
									selector:(SEL)selector
{
	if(!self.authorized)
		return;
	
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
	
//	DebugLog(@"x_verify_credentials_authorization: %@", credentials);
	
	HTTPParamList* params = [HTTPParamList paramList];
	[params addPlainParamWithName:@"message" value:message];
	[params addPlainParamWithName:@"title" value:title];
	[params addPlainParamWithName:@"description" value:description];
	[params addFileParamWithName:@"media" 
					   fillename:filename 
						 content:video 
					 contentType:contentType];
	[params addPlainParamWithName:@"x_auth_service_provider" value:twitterUrl];
	[params addPlainParamWithName:@"x_verify_credentials_authorization" value:credentials];

	[self cancelCurrentConnection];
	
	httpUtil = [[HTTPUtil alloc] init];
	[httpUtil sendAsyncPostRequestWithURL:[NSURL URLWithString:TWITVID_UPLOAD_URL] 
							   parameters:params
				   additionalHeaderFields:nil
						  timeoutInterval:timeout 
									   to:delegate 
								 selector:selector];
}

@end
