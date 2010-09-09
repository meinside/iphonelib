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
//  last update: 10.09.09.
//

#import "AVAudioPlayerWrapper.h"

#import "Logging.h"


@implementation AVAudioPlayerWrapper

static AVAudioPlayerWrapper* _player;

- (void)playNextSound:(NSTimer*)timer
{
	@synchronized(self)
	{
		if([filenames count] <= 0)
		{
			DebugLog(@"nothing in the play queue");
			
			[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];

			return;
		}
		
		NSString* filename = [filenames objectAtIndex:0];

		[lastPlayedFilename release];
		lastPlayedFilename = [filename copy];

		NSString* filepath = [FileUtil pathOfFile:filename withPathType:filePathType];
		[filenames removeObjectAtIndex:0];
		
		[player release];
		player = nil;
		
		if(![FileUtil fileExistsAtPath:filepath])
		{
			DebugLog(@"given file does not exist: %@", filename);

			[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];

			return;
		}

		[delegate audioPlayerWrapper:self willStartPlayingFilename:filename];
		
		NSError* error;
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
														error:&error];
		[player setDelegate:self];
		[player play];
		
		[delegate audioPlayerWrapper:self didStartPlayingFilename:filename];
	}
}

- (void)stopAndPlayNextSound:(NSTimer*)timer
{
	@synchronized(self)
	{
		if([filenames count] <= 0)
		{
			DebugLog(@"nothing in the play queue");
			
			[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];
			
			return;
		}
		
		DebugLog(@"playing next sound");

		NSString* filename = [filenames objectAtIndex:0];
		
		[lastPlayedFilename release];
		lastPlayedFilename = [filename copy];
		
		NSString* filepath = [FileUtil pathOfFile:filename withPathType:filePathType];
		[filenames removeObjectAtIndex:0];
		
		if(player)
		{
			if([player isPlaying])
			{
				[player stop];
				
				[delegate audioPlayerWrapper:self didFinishPlayingFilename:lastPlayedFilename];
				[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];
			}
			[player release];
			player = nil;
		}

		if(![FileUtil fileExistsAtPath:filepath])
		{
			DebugLog(@"given file does not exist: %@", filename);
			
			[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];
			
			return;
		}
		
		[delegate audioPlayerWrapper:self willStartPlayingFilename:filename];
		
		NSError* error;
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
														error:&error];
		[player setDelegate:self];
		[player play];
		
		[delegate audioPlayerWrapper:self didStartPlayingFilename:filename];
		
		[playTimer invalidate];
		[playTimer release];
		playTimer = [[NSTimer scheduledTimerWithTimeInterval:gap 
													  target:self 
													selector:@selector(stopAndPlayNextSound:) 
													userInfo:nil 
													 repeats:NO] retain];
	}
}

- (void)stopAndPlay:(NSTimer*)timer
{
	@synchronized(self)
	{
		[playTimer invalidate];
		[playTimer release];
		playTimer = [[NSTimer scheduledTimerWithTimeInterval:0 
													  target:self 
													selector:@selector(stopAndPlayNextSound:) 
													userInfo:nil 
													 repeats:NO] retain];
	}
}

- (id)init
{
	if((self = [super init]))
	{
		//nothing to do

		DebugLog(@"AVAudioPlayerWrapper initialized");
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

		DebugLog(@"AVAudioPlayerWrapper disposed");
	}
}

- (BOOL)playSound:(NSString *)filename pathType:(PathType)pathType
{
	DebugLog(@"playing sound filename: %@", filename);
	
	filePathType = pathType;
	
	[lastPlayedFilename release];
	lastPlayedFilename = [filename copy];
	
	NSString* filepath = [FileUtil pathOfFile:filename 
								 withPathType:filePathType];
	
	if(![FileUtil fileExistsAtPath:filepath])
	{
		DebugLog(@"given file does not exist: %@", filename);
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
		
		[delegate audioPlayerWrapper:self willStartPlayingFilename:filename];
		
		NSError* error;
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
														error:&error];
		[player setDelegate:self];
		[player play];
		
		[delegate audioPlayerWrapper:self didStartPlayingFilename:filename];
	}
	
	return YES;
}

- (BOOL)playSound:(NSString*)filename
{
	return [self playSound:filename 
				  pathType:PathTypeResource];
}

- (void)playSounds:(NSArray*)someFilenames pathType:(PathType)pathType withGap:(float)someGap afterEachFinish:(BOOL)startAfterPreviousSoundsFinish delay:(float)someDelay
{
	DebugLog(@"playing sound filenames: %@", someFilenames);
	
	@synchronized(self)
	{
		filePathType = pathType;
		
		startAfterEachFinish = startAfterPreviousSoundsFinish;
		
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
													selector:(startAfterEachFinish ? @selector(playNextSound:) : @selector(stopAndPlay:))
													userInfo:nil 
													 repeats:NO] retain];
	}
}

- (void)playSounds:(NSArray*)someFilenames withGap:(float)someGap afterEachFinish:(BOOL)startAfterPreviousSoundsFinish delay:(float)someDelay
{
	[self playSounds:someFilenames 
			pathType:PathTypeResource 
			 withGap:someGap 
	 afterEachFinish:startAfterEachFinish 
			   delay:someDelay];
}

- (void)stopSound
{
	DebugLog(@"stopping sound: %@", lastPlayedFilename);

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
			if([player isPlaying])
			{
				[player stop];

				[delegate audioPlayerWrapper:self didFinishPlayingFilename:lastPlayedFilename];
				[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];
			}
			[player release];
			player = nil;
		}
	}
}

- (void)setDelegate:(id<AVAudioPlayerWrapperDelegate>)newDelegate
{
	[delegate release];
	delegate = [newDelegate retain];
}

- (void)dealloc
{
	[playTimer invalidate];
	[playTimer release];
	
	[player stop];
	[player release];
	
	[filenames release];
	
	[lastPlayedFilename release];
	
	[delegate release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark av audio player delegate functions

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
	if(flag)
	{
		[delegate audioPlayerWrapper:self didFinishPlayingFilename:lastPlayedFilename];

		@synchronized(self)
		{
			if([filenames count] > 0)
			{
				if(startAfterEachFinish)
				{
					DebugLog(@"playing next sound");
					
					[playTimer invalidate];
					[playTimer release];
					playTimer = [[NSTimer scheduledTimerWithTimeInterval:gap 
																  target:self 
																selector:@selector(playNextSound:) 
																userInfo:nil 
																 repeats:NO] retain];
				}
			}
			else
			{
				DebugLog(@"no more files left in the play queue");

				[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:YES];
			}
		}
	}
	else
	{
		DebugLog(@"did finish playing unsuccessfully");
		
		[delegate audioPlayerWrapper:self didFinishPlayingSuccessfully:NO];
	}
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	DebugLog(@"playing interruption began");
	
	//do what?
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)aPlayer
{
	DebugLog(@"playing interruption ended");
	
	//do what?
}

@end
