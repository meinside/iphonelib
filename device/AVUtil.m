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
//  AVUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 10.05.09.
//

#import "AVUtil.h"


@implementation AVUtil

#pragma mark -
#pragma mark functions related to audio session

+ (BOOL)setActive:(BOOL)activeOrNot
{
	NSError* error;
	return [[AVAudioSession sharedInstance] setActive:activeOrNot error:&error];
}

+ (BOOL)setAudioSessionCategory:(NSString*)category
{
	NSError* error;
	return [[AVAudioSession sharedInstance] setCategory:category error:&error];
}

#pragma mark -
#pragma mark functions for managing audio files

+ (NSTimeInterval)estimatedDurationOfAudioFile:(NSString*)filepath
{
	if(!filepath)
	{
		DebugLog(@"filepath is nil");
		return 0;
	}
	
	NSTimeInterval seconds;
	UInt32 propertySize = sizeof(seconds);
	OSStatus err;
	AudioFileID audioFileId;
	
	NSURL* baseURL = [NSURL fileURLWithPath:filepath isDirectory:NO];
	if(!baseURL)
	{
		DebugLog(@"base url is nil with filepath: %@", filepath);
		return 0;
	}

	err = AudioFileOpenURL((CFURLRef)baseURL, kAudioFileReadPermission, 0 /* kAudioFile*Type */, &audioFileId);
	
	if(err == noErr)
	{
		err = AudioFileGetProperty(audioFileId, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
		AudioFileClose(audioFileId);
		if(err == noErr)
			return seconds;
		else
			DebugLog(@"error with AudioFileGetProperty()");
	}
	else
		DebugLog(@"error with AudioFileOpenURL()");

	return 0;
}


@end
