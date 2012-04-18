//
//  OAuthProvider+Twitter.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 1. 10.
//
//  last update: 12.04.18.
//

#pragma once
#import <Foundation/Foundation.h>

#import "OAuthProvider.h"


#define TWITTER_MESSAGE_MAX_LENGTH 140

#define TWITTER_VERIFY_CREDENTIALS_URL @"https://api.twitter.com/1/account/verify_credentials.xml"
#define TWITTER_STATUSES_UPDATE_URL @"https://api.twitter.com/1/statuses/update.xml"
#define TWITTER_STATUSES_RETWEET_URL @"https://api.twitter.com/1/statuses/retweet/%@.xml"
#define TWITTER_FRIENDSHIP_CHECK_URL @"https://api.twitter.com/1/friendships/exists.xml"
#define TWITTER_FOLLOW_URL @"https://api.twitter.com/1/friendships/create.xml"
#define TWITTER_UNFOLLOW_URL @"https://api.twitter.com/1/friendships/destroy.xml"
#define TWITTER_DIRECT_MESSAGE_WRITE_URL @"https://api.twitter.com/1/direct_messages/new.xml"

//media upload services
#define YFROG_UPLOAD_URL @"https://yfrog.com/api/xauth_upload"
#define TWITPIC_UPLOAD_URL @"http://api.twitpic.com/2/upload.xml"
#define IMGLY_UPLOAD_URL @"http://img.ly/api/2/upload.xml"
#define TWITVID_UPLOAD_URL @"http://im.twitvid.com/api/upload "


@interface OAuthProvider (OAuthProviderTwitterExtension)

/*
 * functions for twitter service
 * - http://dev.twitter.com/doc
 */

//http://dev.twitter.com/doc/get/account/verify_credentials
- (NSDictionary*)verifyCredentials;

//http://dev.twitter.com/doc/post/statuses/update
- (NSDictionary*)updateStatus:(NSString*)status	//status text
					inReplyTo:(NSString*)statusId	//existing status' id that this update replies to (nil if none)
					 latitude:(NSString*)latitude	//latitude: -90.0 ~ +90.0 (nil if none)
					longitude:(NSString*)longitude	//longitude: -180.0 ~ +180.0 (nil if none)
					  placeId:(NSString*)placeId		//place id that this update will be attached to (nil if none)
			displayCoordinate:(BOOL)displayCoordinate;

//http://dev.twitter.com/doc/post/statuses/retweet/:id
- (NSDictionary*)retweetStatusId:(NSString*)statusId;

//http://dev.twitter.com/doc/get/friendships/exists
- (NSDictionary*)isFollowingUser:(NSString*)user;
- (NSDictionary*)isFollowedByUser:(NSString*)user;

//http://dev.twitter.com/doc/post/friendships/create
//if already following given user, HTTP 403 will be returned
- (NSDictionary*)followUserId:(NSString*)userId;
- (NSDictionary*)followUser:(NSString*)screenName;

//http://dev.twitter.com/doc/post/friendships/destroy
- (NSDictionary*)unfollowUserId:(NSString*)userId;
- (NSDictionary*)unfollowUser:(NSString*)screenName;

//http://dev.twitter.com/doc/post/direct_messages/new
- (NSDictionary*)sendDirectMessage:(NSString*)message toUserId:(NSString*)userId;
- (NSDictionary*)sendDirectMessage:(NSString*)message toUser:(NSString*)screenName;


/* ---------------------------------------------------------------- */

/*
 * functions for yfrog service
 * - http://code.google.com/p/imageshackapi/wiki/TwitterAuthentication
 * - http://code.google.com/p/imageshackapi/wiki/YFROGupload
 * 
 * returns media url
 * 
 */

- (NSString*)uploadMediaToYfrogWithDeveloperKey:(NSString*)devKey 
											 media:(NSData*)media 
										  filename:(NSString*)filename
									   contentType:(NSString*)contentType;
- (void)asyncUploadMediaToYfrogWithDeveloperKey:(NSString*)devKey 
										  media:(NSData*)media 
									   filename:(NSString*)filename
									contentType:(NSString*)contentType
											 to:(id)delegate
									   selector:(SEL)selector;


/* ---------------------------------------------------------------- */

/*
 * functions for twitpic service
 * - http://dev.twitpic.com/docs/2/upload/
 * 
 * returns media url
 * 
 */
- (NSString*)uploadMediaToTwitpicWithDeveloperKey:(NSString*)devKey 
										  message:(NSString*)message
											media:(NSData*)media 
										 filename:(NSString*)filename
									  contentType:(NSString*)contentType;
- (void)asyncUploadMediaToTwitpicWithDeveloperKey:(NSString*)devKey 
										  message:(NSString*)message
											media:(NSData*)media 
										 filename:(NSString*)filename
									  contentType:(NSString*)contentType
											   to:(id)delegate
										 selector:(SEL)selector;


/* ---------------------------------------------------------------- */

/*
 * functions for img.ly service
 * - http://img.ly/api/docs
 * 
 * returns media url
 * 
 */
- (NSString*)uploadMediaToImglyWithMessage:(NSString*)message
									 media:(NSData*)media 
								  filename:(NSString*)filename
							   contentType:(NSString*)contentType;
- (void)asyncUploadMediaToImglyWithMessage:(NSString*)message
									 media:(NSData*)media 
								  filename:(NSString*)filename
							   contentType:(NSString*)contentType
										to:(id)delegate
								  selector:(SEL)selector;


/* ---------------------------------------------------------------- */

/*
 * functions for twitvid service
 * - http://twitvid.pbworks.com/Twitvid%C2%A0API%C2%A0Method%3A%C2%A0upload
 * 
 * returns media url
 * 
 */
- (NSString*)uploadVideoToTwitvidWithMessage:(NSString*)message 
									   title:(NSString*)title 
								 description:(NSString*)description
									   video:(NSData*)video 
									filename:(NSString*)filename
								 contentType:(NSString*)contentType;
- (void)asyncUploadVideoToTwitvidWithMessage:(NSString*)message 
									   title:(NSString*)title 
								 description:(NSString*)description
									   video:(NSData*)video 
									filename:(NSString*)filename
								 contentType:(NSString*)contentType
										  to:(id)delegate
									selector:(SEL)selector;

@end
