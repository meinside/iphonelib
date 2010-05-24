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
//  AudioQueuePlayerPool.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 20.
//
//  last update: 10.05.24.
//

#import "AudioQueuePlayerPool.h"


@implementation AudioQueuePlayerPool

#pragma mark -
#pragma mark initializers

- (id)initWithFilepaths:(NSArray*)filepaths
{
	return [self initWithFilepaths:filepaths 
					  samplingRate:0.0f];
}

- (id)initWithFilepaths:(NSArray*)filepaths 
		   samplingRate:(float)multiplier
{
	if(self = [super init])
	{
		audioQueues = [[NSMutableArray alloc] init];
		
		for(NSString* filepath in filepaths)
		{
			AudioQueuePlayer* audioQueue;
			
			if(multiplier > 0.0f)
				audioQueue = [[AudioQueuePlayer alloc] initWithFilepath:filepath 
														   samplingRate:multiplier];
			else
				audioQueue = [[AudioQueuePlayer alloc] initWithFilepath:filepath];
			
			[audioQueue setDelegate:self];

			[audioQueues addObject:audioQueue];
			[audioQueue release];
		}
		
		currentPlayingCount = 0;
		
		delegate = nil;
	}
	return self;
}

- (void)setDelegate:(id<AudioQueuePlayerPoolDelegate>)newDelegate
{
	[delegate release];
	delegate = nil;

	delegate = [newDelegate retain];
}

- (id<AudioQueuePlayerPoolDelegate>)delegate
{
	return delegate;
}

#pragma mark -
#pragma mark functions for manipulating each audio queue

- (uint)numAudioQueues
{
	return [audioQueues count];
}

- (AudioQueuePlayer*)audioQueuePlayerAtIndex:(NSUInteger)index
{
	return [audioQueues objectAtIndex:index];
}

- (BOOL)isPlayingAtIndex:(NSUInteger)index
{
	return ((AudioQueuePlayer*)[audioQueues objectAtIndex:index]).isRunning;
}

- (unsigned int)currentPlayingCount
{
	return currentPlayingCount;
}

- (BOOL)didAllStartPlaying
{
	return currentPlayingCount == [audioQueues count];
}

- (BOOL)didAllStopPlaying
{
	return currentPlayingCount == 0;
}

- (float)durationAtIndex:(NSUInteger)index
{
	return [[audioQueues objectAtIndex:index] duration];
}

- (float)currentTimeAtIndex:(NSUInteger)index
{
	return [[audioQueues objectAtIndex:index] currentTime];
}

- (float)volumeAtIndex:(NSUInteger)index
{
	return [[audioQueues objectAtIndex:index] volume];
}

- (void)setVolume:(float)volume 
		  atIndex:(NSUInteger)index
{
	return [[audioQueues objectAtIndex:index] setVolume:volume];
}

#pragma mark -
#pragma mark functions for manipulating all audio queues at once

- (void)playAll
{
	for(AudioQueuePlayer* player in audioQueues)
	{
		[player setStartTime:NULL];
		[player play];
	}
}

- (void)playAllAtTimestamp:(AudioTimeStamp)timestamp
{
	for(AudioQueuePlayer* player in audioQueues)
	{
		[player setStartTime:&timestamp];
		[player play];
	}
}

- (void)stopAll
{
	for(AudioQueuePlayer* player in audioQueues)
	{
		[player stop:YES];
	}
}

#pragma mark -
#pragma mark etc.

- (void)audioQueuePlayer:(AudioQueuePlayer*)player did:(AudioQueuePlayerAction)what
{
	switch(what)
	{
		case AudioQueuePlayerStartedPlaying:
			currentPlayingCount ++;
			DebugLog(@"AudioQueuePlayer[%d] started playing", [audioQueues indexOfObject:player]);
			break;
		case AudioQueuePlayerStoppedPlaying:
			currentPlayingCount --;
			if(currentPlayingCount == 0)
				[delegate allStoppedPlaying];
			DebugLog(@"AudioQueuePlayer[%d] stopped playing", [audioQueues indexOfObject:player]);
			break;
	}
}

- (void)dealloc
{
	[delegate release];
	[audioQueues release];
	
	[super dealloc];
}

@end
