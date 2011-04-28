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
//  AudioQueuePlayerWrapper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 28.
//
//  last update: 11.04.28.
//

#import "AudioQueuePlayerWrapper.h"

#import "Logging.h"


//for singleton pattern
static AudioQueuePlayerWrapper* _manager;

@implementation AudioQueuePlayerWrapper

@synthesize delegate;

#pragma mark -
#pragma mark initializers

- (id)init
{
	if((self = [super init]))
	{
		lastTime = 0.0f;
		lastSeekTime = 0.0f;
		currentSamplingRateMultiplier = 1.0f;

		initialized = NO;
	}
	return self;
}

- (id)initWithFilename:(NSString*)filename andSamplingRateMultiplier:(float)multiplier
{
	return [self initWithFilename:filename pathType:PathTypeResource andSamplingRateMultiplier:multiplier];
}

- (id)initWithFilename:(NSString*)filename pathType:(PathType)pathType andSamplingRateMultiplier:(float)multiplier
{
	AudioQueuePlayerWrapper* initee = [[AudioQueuePlayerWrapper alloc] init];
	[initee setFileNamed:filename pathType:pathType withSamplingRateMultiplier:multiplier];
	
	return initee;
}

- (BOOL)isInitialized
{
	return initialized;
}

+ (AudioQueuePlayerWrapper*)sharedInstance
{
	if(!_manager)
	{
		_manager = [[AudioQueuePlayerWrapper alloc] init];
	}
	
	return _manager;
}

+ (void)disposeSharedInstance
{
	if(_manager)
	{
		[_manager release];
		_manager = nil;
	}
}

#pragma mark -
#pragma mark setter functions

- (void)setFileNamed:(NSString*)filename withSamplingRateMultiplier:(float)multiplier
{
	[self setFileNamed:filename pathType:PathTypeResource withSamplingRateMultiplier:multiplier];
}

- (void)setFileNamed:(NSString*)filename pathType:(PathType)pathType withSamplingRateMultiplier:(float)multiplier
{
	DebugLog(@"initializing...");
	
	@synchronized(self)
	{
		if(player)
		{
			if(player.isRunning)
			{
				lastTime = [player currentTime];
				
				[player stop:YES];
			}
			player.delegate = nil;
			
			[player release];
			player = nil;
		}
		
		if(currentURL)
			[currentURL release];
		currentURL = nil;
		
		lastTime = 0.0f;
		lastSeekTime = 0.0f;
		currentSamplingRateMultiplier = multiplier;

		currentURL = [[NSURL fileURLWithPath:[FileUtil pathOfFile:filename 
													 withPathType:pathType]] retain];
		
		player = [[AudioQueuePlayer alloc] initWithURL:currentURL 
										  samplingRate:currentSamplingRateMultiplier];
		player.delegate = self;
		
		initialized = (player != nil);
	}
}

- (void)changeSamplingRateMultiplierTo:(float)multiplier
{
	if(!initialized)
		DebugLog(@"not initialized yet");
	
	if(currentSamplingRateMultiplier == multiplier)
		return;	//not changed

	if(multiplier <= 0.0f)
	{
		DebugLog(@"sampling rate multiplier must be bigger than 0");
		return;
	}
	
	@synchronized(self)
	{
		BOOL wasPlaying = NO;
		
		if(player)
		{
			player.delegate = nil;	//not to call 'stopped' delegate function

			wasPlaying = player.isRunning;
			lastTime = [self currentTime];
			if(wasPlaying)
				[player stop:YES];
			[player release];
			player = nil;
		}
		
		Float64 oldSamplingRateMultiplier = currentSamplingRateMultiplier;
		currentSamplingRateMultiplier = multiplier;
		
		player = [[AudioQueuePlayer alloc] initWithURL:currentURL 
										  samplingRate:currentSamplingRateMultiplier];
		
		if(wasPlaying)
		{
			lastSeekTime = lastTime * oldSamplingRateMultiplier / currentSamplingRateMultiplier;
			[player seekTo:lastSeekTime];
		}
		
		player.delegate = self;
	}
}

#pragma mark -
#pragma mark sound property functions

- (Float64)currentTime
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		if(!player)
			return 0.0f;
		
//		DebugLog(@"lastSeekTime = %f, lastTime = %f, currentTime = %f", lastSeekTime, lastTime, [player currentTime]);
		
		if(player.isRunning)
			return lastSeekTime + [player currentTime];
		else
			return lastSeekTime + lastTime;
	}
}

- (NSTimeInterval)duration
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		return [player duration] / currentSamplingRateMultiplier;
	}
}

- (BOOL)isPlaying
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		if(!player)
			return NO;
		
		return player.isRunning;
	}
}

#pragma mark -
#pragma mark sound manipulation functions

- (void)play
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		lastSeekTime = 0.0f;
		lastTime = 0.0f;
		
		[player play:NO];
	}
}

- (void)stop
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		lastTime = [self currentTime];
		[player stop:YES];
	}
}

- (void)resume
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		[player play:YES];
	}
}

- (void)seekTo:(Float64)seconds
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		lastSeekTime = seconds;
		[player seekTo:lastSeekTime];
	}
}

- (void)seekToOriginal:(Float64)seconds
{
	if(!initialized)
		DebugLog(@"not initialized yet");

	@synchronized(self)
	{
		lastSeekTime = seconds / currentSamplingRateMultiplier;
		[player seekTo:lastSeekTime];
	}
}


#pragma mark -
#pragma mark delegate functions

- (void)audioQueuePlayer:(AudioQueuePlayer*)player did:(AudioQueuePlayerAction)what
{
	[delegate audioQueuePlayerWrapper:self 
								  did:what];
}


#pragma mark -
#pragma mark memory management

- (void)dealloc
{
	if(player && player.isRunning)
		[player stop:YES];
	[player release];

	[currentURL release];
	
	[super dealloc];
}

@end
