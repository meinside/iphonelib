//
//  AVAudioPlayerWrapper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 08. 22.
//
//  last update: 12.01.27.
//

#import "AVAudioPlayerWrapper.h"

#import "Logging.h"


@implementation AVAudioPlayerWrapper

static AVAudioPlayerWrapper* _player;

@synthesize delegate;

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
		player.volume = volume;
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
		player.volume = volume;
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
		volume = 1.0f;

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
		player.volume = volume;
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
	DebugLog(@"playing sound filenames (afterEachFinish = %d): %@", startAfterPreviousSoundsFinish, someFilenames);
	
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
	 afterEachFinish:startAfterPreviousSoundsFinish 
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

- (NSTimeInterval)getCurrentTime
{
	return player.currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)newCurrentTime
{
	player.currentTime = newCurrentTime;
}

- (float)currentVolume
{
	return volume;
}

- (void)setVolume:(float)newVolume
{
	volume = newVolume;
	[player setVolume:volume];
}

- (BOOL)isPlaying
{
	return player.isPlaying;
}

- (AVAudioPlayer*)player
{
	return player;
}

- (void)dealloc
{
	[playTimer invalidate];
	[playTimer release];
	
	[player stop];
	[player release];
	
	[filenames release];
	
	[lastPlayedFilename release];
	
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

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)aPlayer
{
	if([delegate respondsToSelector:@selector(audioPlayerWrapper:beginInterruption:)])
	{
		[delegate audioPlayerWrapper:self 
				   beginInterruption:aPlayer];
	}

	DebugLog(@"playing interruption began");
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)aPlayer
{
	if([delegate respondsToSelector:@selector(audioPlayerWrapper:endInterruption:)])
	{
		[delegate audioPlayerWrapper:self 
					 endInterruption:aPlayer];
	}

	DebugLog(@"playing interruption ended");
}

@end
