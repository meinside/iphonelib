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
//  AVAudioPlayerWrapper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 08. 22.
//
//  last update: 10.08.22.
//

#import "AVAudioPlayerWrapper.h"

#import "FileUtil.h"

#import "Logging.h"


@implementation AVAudioPlayerWrapper

static AVAudioPlayerWrapper* _player;

- (void)playNextSound:(NSTimer*)timer
{
	@synchronized(self)
	{
		if([filenames count] <= 0)
		{
			DebugLog(@"no more files in the play queue");
			return;
		}
		
		NSString* filename = [filenames objectAtIndex:0];
		NSString* filepath = [FileUtil pathOfFile:filename withPathType:PathTypeResource];
		[filenames removeObjectAtIndex:0];
		
		if(![FileUtil fileExistsAtPath:filepath])
		{
			DebugLog(@"given resource file does not exist: %@", filename);
			return;
		}
		
		[player release];
		player = nil;
		
		NSError* error;
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
														error:&error];
		[player setDelegate:self];
		
		[player play];
	}
}

- (id)init
{
	if((self = [super init]))
	{
		//nothing to do
	}
	return self;
}

+ (AVAudioPlayerWrapper*)sharedInstance
{
	@synchronized(self)
	{
		if(!_player)
		{
			_player = [[AVAudioPlayerWrapper alloc] init];
		}
	}
	return _player;
}

+ (void)disposeSharedInstance
{
	@synchronized(self)
	{
		[_player release];
		_player = nil;
	}
}

- (BOOL)playSound:(NSString*)filename
{
	NSString* filepath = [FileUtil pathOfFile:filename withPathType:PathTypeResource];
	
	if(![FileUtil fileExistsAtPath:filepath])
	{
		DebugLog(@"given resource file does not exist: %@", filename);
		return NO;
	}
	
	@synchronized(self)
	{
		if(playTimer)
		{
			[playTimer invalidate];
			[playTimer release];
			playTimer = nil;
		}
		
		[filenames release];
		filenames = nil;
		
		if(player)
		{
			[player stop];
			[player release];
			player = nil;
		}
		
		NSError* error;
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
														error:&error];
		[player setDelegate:self];
		
		[player play];
	}
	
	return YES;
}

- (void)playSounds:(NSArray*)someFilenames withGap:(float)someGap delay:(float)someDelay
{	
	@synchronized(self)
	{
		gap = someGap;
		
		if(playTimer)
		{
			[playTimer invalidate];
			[playTimer release];
			playTimer = nil;
		}
		
		[filenames release];
		filenames = nil;
		
		filenames = [[NSMutableArray arrayWithArray:someFilenames] retain];
		
		if(player)
		{
			[player stop];
			[player release];
			player = nil;
		}
		
		playTimer = [[NSTimer scheduledTimerWithTimeInterval:someDelay 
													  target:self 
													selector:@selector(playNextSound:) 
													userInfo:nil 
													 repeats:NO] retain];
	}
}

- (void)stopSound
{
	@synchronized(self)
	{
		if(playTimer)
		{
			[playTimer invalidate];
			[playTimer release];
			playTimer = nil;
		}
		
		[filenames release];
		filenames = nil;
		
		if(player)
		{
			[player stop];
			[player release];
			player = nil;
		}
	}
}

- (void)dealloc
{
	[player release];
	
	[filenames release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark av audio player delegate functions

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
	if(flag)
	{
		DebugLog(@"playing next sound");
		
		@synchronized(self)
		{
			[playTimer invalidate];
			[playTimer release];
			playTimer = [[NSTimer scheduledTimerWithTimeInterval:gap 
														  target:self 
														selector:@selector(playNextSound:) 
														userInfo:nil 
														 repeats:NO] retain];
		}
	}
}

@end
