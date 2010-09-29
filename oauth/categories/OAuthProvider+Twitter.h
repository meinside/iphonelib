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
//  OAuthProvider+Twitter.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 1. 10.
//
//  last update: 10.09.29.
//

#pragma once
#import <Foundation/Foundation.h>

#import "OAuthProvider.h"


#define TWITTER_MESSAGE_MAX_LENGTH 140

#define TWITTER_VERIFY_CREDENTIALS_URL @"http://api.twitter.com/1/account/verify_credentials.xml"
#define TWITTER_STATUSES_UPDATE_URL @"http://api.twitter.com/1/statuses/update.xml"
#define TWITTER_FRIENDSHIP_CHECK_URL @"http://api.twitter.com/1/friendships/exists.xml"
#define TWITTER_FOLLOW_URL @"http://api.twitter.com/1/friendships/create.xml"
#define TWITTER_UNFOLLOW_URL @"http://api.twitter.com/1/friendships/destroy.xml"
#define TWITTER_DIRECT_MESSAGE_WRITE_URL @"http://api.twitter.com/1/direct_messages/new.xml"

#define YFROG_UPLOAD_URL @"https://yfrog.com/api/xauth_upload"

#define TWITPIC_UPLOAD_URL @"http://api.twitpic.com/2/upload.xml"


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

@end
