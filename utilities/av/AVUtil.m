//
//  AVUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 2014.04.07.
//

#import "AVUtil.h"

#import "Logging.h"


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
	
	NSURL* url = [NSURL fileURLWithPath:filepath isDirectory:NO];
	if(!url)
	{
		DebugLog(@"base url is nil with filepath: %@", filepath);
		return 0;
	}
	
	return [self estimatedDurationOfAudioFileurl:url];
}

+ (NSTimeInterval)estimatedDurationOfAudioFileurl:(NSURL*)url
{
	NSTimeInterval seconds;
	UInt32 propertySize = sizeof(seconds);
	OSStatus err;
	AudioFileID audioFileId;
	
	err = AudioFileOpenURL((CFURLRef)url, kAudioFileReadPermission, 0 /* kAudioFile*Type */, &audioFileId);
	
	if(err == noErr)
	{
		err = AudioFileGetProperty(audioFileId, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
		AudioFileClose(audioFileId);
		if(err == noErr)
			return seconds;
		else
			DebugLog(@"AudioFileGetProperty failed: %d", err);
	}
	else
		DebugLog(@"AudioFileOpenURL failed: %d", (int)err);
	
	return 0;
}


@end
