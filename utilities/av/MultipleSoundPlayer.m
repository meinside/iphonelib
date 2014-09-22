//
//  MultipleSoundPlayer.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 07. 18.
//
//  last update: 2014.09.22.
//

#import "MultipleSoundPlayer.h"

#import "Logging.h"


@implementation MultipleSoundPlayer

static MultipleSoundPlayer* _mplayer;

@synthesize delegate;
@synthesize filepaths = _filepaths;
@synthesize player = _player;
@synthesize playTimer = _playTimer;
@synthesize lastPlayedFilepath = _lastPlayedFilepath;

- (void)playNextSound:(NSTimer*)timer
{
	@synchronized(self)
	{
		if([self.filepaths count] <= 0)
		{
			DebugLog(@"nothing in the play queue");
			
			[delegate player:self didFinishPlayingSuccessfully:NO];

			return;
		}
		
		NSString* filepath = [self.filepaths objectAtIndex:0];
		self.lastPlayedFilepath = filepath;
		[self.filepaths removeObjectAtIndex:0];

		self.player = nil;
		
		if(![FileUtil fileExistsAtPath:filepath])
		{
			DebugLog(@"given file does not exist: %@", filepath);

			[delegate player:self didFinishPlayingSuccessfully:NO];

			return;
		}

		[delegate player:self willStartPlayingFilepath:filepath];
		
		NSError* error;
		self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
															  error:&error] autorelease];
		self.player.delegate = self;
		self.player.volume = volume;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
		self.player.enableRate = YES;
		self.player.rate = rate;
#endif

		[self.player prepareToPlay];
		[self.player play];
		
		[delegate player:self didStartPlayingFilepath:filepath];
	}
}

- (void)stopAndPlayNextSound:(NSTimer*)timer
{
	@synchronized(self)
	{
		if([self.filepaths count] <= 0)
		{
			DebugLog(@"nothing in the play queue");
			
			[delegate player:self didFinishPlayingSuccessfully:NO];
			
			return;
		}
		
		DebugLog(@"playing next sound");

		NSString* filepath = [self.filepaths objectAtIndex:0];
		self.lastPlayedFilepath = filepath;
		[self.filepaths removeObjectAtIndex:0];
		
		if(self.player)
		{
			if([self.player isPlaying])
			{
				[self.player stop];
				
				[delegate player:self didFinishPlayingFilepath:self.lastPlayedFilepath];
				[delegate player:self didFinishPlayingSuccessfully:NO];
			}
			self.player = nil;
		}

		if(![FileUtil fileExistsAtPath:filepath])
		{
			DebugLog(@"given file does not exist: %@", filepath);
			
			[delegate player:self didFinishPlayingSuccessfully:NO];
			
			return;
		}
		
		[delegate player:self willStartPlayingFilepath:filepath];
		
		NSError* error;
		self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
															  error:&error] autorelease];
		self.player.delegate = self;
		self.player.volume = volume;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
		self.player.enableRate = YES;
		self.player.rate = rate;
#endif

		[self.player prepareToPlay];
		[self.player play];
		
		[delegate player:self didStartPlayingFilepath:filepath];
		
		[self.playTimer invalidate];
		self.player = nil;
		self.playTimer = [NSTimer scheduledTimerWithTimeInterval:gap 
														  target:self 
														selector:@selector(stopAndPlayNextSound:) 
														userInfo:nil 
														 repeats:NO];
	}
}

- (void)stopAndPlay:(NSTimer*)timer
{
	@synchronized(self)
	{
		[self.playTimer invalidate];
		self.playTimer = nil;
		self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0 
														  target:self 
														selector:@selector(stopAndPlayNextSound:) 
														userInfo:nil 
														 repeats:NO];
	}
}

- (id)init
{
	if((self = [super init]))
	{
		volume = 1.0f;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
		rate = 1.0f;
#endif

		DebugLog(@"MultipleSoundPlayer initialized");
	}
	return self;
}

+ (MultipleSoundPlayer*)sharedInstance
{
	@synchronized(self)
	{
		if(!_mplayer)
		{
			_mplayer = [[MultipleSoundPlayer alloc] init];
		}
	}
	return _mplayer;
}

+ (void)disposeSharedInstance
{
	@synchronized(self)
	{
		[_mplayer release];
		_mplayer = nil;

		DebugLog(@"MultipleSoundPlayer disposed");
	}
}

- (BOOL)playSoundWithFilepath:(NSString*)filepath
{
	DebugLog(@"playing sound with filepath: %@", filepath);

	self.lastPlayedFilepath = filepath;
	
	if(![FileUtil fileExistsAtPath:filepath])
	{
		DebugLog(@"given file does not exist: %@", filepath);
		return NO;
	}
	
	@synchronized(self)
	{
		if(self.playTimer)
		{
			[self.playTimer invalidate];
			self.playTimer = nil;
		}
		
		self.filepaths = nil;
		
		if(self.player)
		{
			[self.player stop];
			self.player = nil;
		}
		
		[delegate player:self willStartPlayingFilepath:filepath];
		
		NSError* error;
		self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath] 
															  error:&error] autorelease];
		self.player.delegate = self;
		self.player.volume = volume;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
		self.player.enableRate = YES;
		self.player.rate = rate;
#endif

		[self.player prepareToPlay];
		[self.player play];
		
		[delegate player:self didStartPlayingFilepath:filepath];
	}
	
	return YES;
}

- (BOOL)playSound:(NSString*)filename withPathType:(PathType)pathType
{
	return [self playSoundWithFilepath:[FileUtil pathOfFile:filename 
											   withPathType:pathType]];
}

- (void)playSoundFiles:(NSArray*)someFilepaths 
			   withGap:(float)someGap 
	   afterEachFinish:(BOOL)startAfterPreviousSoundsFinish 
				 delay:(float)someDelay
{
	DebugLog(@"playing sound filepaths (afterEachFinish = %d): %@", startAfterPreviousSoundsFinish, someFilepaths);
	
	@synchronized(self)
	{
		startAfterEachFinish = startAfterPreviousSoundsFinish;
		gap = someGap;
		
		if(self.playTimer)
		{
			[self.playTimer invalidate];
			self.playTimer = nil;
		}
		
		self.filepaths = [NSMutableArray arrayWithArray:someFilepaths];
		
		if(self.player)
		{
			[self.player stop];
			self.player = nil;
		}
		
		self.playTimer = [NSTimer scheduledTimerWithTimeInterval:someDelay 
														  target:self 
														selector:(startAfterEachFinish ? @selector(playNextSound:) : @selector(stopAndPlay:))
														userInfo:nil 
														 repeats:NO];
	}

}

- (void)playSounds:(NSArray*)someFilenames 
		  pathType:(PathType)pathType 
		   withGap:(float)someGap 
   afterEachFinish:(BOOL)startAfterPreviousSoundsFinish 
			 delay:(float)someDelay
{
	NSMutableArray* filepaths = [NSMutableArray array];
	for(NSString* filename in someFilenames)
	{
		[filepaths addObject:[FileUtil pathOfFile:filename 
									 withPathType:pathType]];
	}

	[self playSoundFiles:filepaths 
				 withGap:someGap 
		 afterEachFinish:startAfterPreviousSoundsFinish 
				   delay:someDelay];
}

- (void)stopSound
{
	DebugLog(@"stopping sound: %@", self.lastPlayedFilepath);

	@synchronized(self)
	{
		if(self.playTimer)
		{
			[self.playTimer invalidate];
			self.playTimer = nil;
		}

		self.filepaths = nil;
		
		if(self.player)
		{
			if([self.player isPlaying])
			{
				[self.player stop];

				[delegate player:self didFinishPlayingFilepath:self.lastPlayedFilepath];
				[delegate player:self didFinishPlayingSuccessfully:NO];
			}
			self.player = nil;
		}
	}
}

- (NSTimeInterval)getCurrentTime
{
	return self.player.currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)newCurrentTime
{
	self.player.currentTime = newCurrentTime;
}

- (float)currentVolume
{
	return volume;
}

- (void)setVolume:(float)newVolume
{
	volume = newVolume;
	[self.player setVolume:volume];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0

- (float)getCurrentRate
{
	@synchronized(self)
	{
		if(self.player)
			return self.player.rate;
		else
		{
			DebugLog(@"player not available");
			return rate;
		}
	}
}

- (void)setCurrentRate:(float)newRate
{
	@synchronized(self)
	{
		rate = newRate;
		if(self.player)
			self.player.rate = rate;
		else
		{
			DebugLog(@"player not available");
		}
	}
}

#endif

- (BOOL)isPlaying
{
	return self.player.isPlaying;
}

- (void)dealloc
{
	[self.playTimer invalidate];
	[_playTimer release];
	
	[self.player stop];
	[_player release];
	
	[_filepaths release];
	
	[_lastPlayedFilepath release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark av audio player delegate functions

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
	if(flag)
	{
		[delegate player:self didFinishPlayingFilepath:self.lastPlayedFilepath];

		@synchronized(self)
		{
			if([self.filepaths count] > 0)
			{
				if(startAfterEachFinish)
				{
					DebugLog(@"playing next sound");
					
					[self.playTimer invalidate];
					self.playTimer = [NSTimer scheduledTimerWithTimeInterval:gap 
																	  target:self 
																	selector:@selector(playNextSound:) 
																	userInfo:nil 
																	 repeats:NO];
				}
			}
			else
			{
				DebugLog(@"no more files left in the play queue");

				[delegate player:self didFinishPlayingSuccessfully:YES];
			}
		}
	}
	else
	{
		DebugLog(@"did finish playing unsuccessfully: %@", self.lastPlayedFilepath);
		
		[delegate player:self didFinishPlayingSuccessfully:NO];
	}
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	DebugLog(@"decode error: %@", error);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)aPlayer
{
	if([delegate respondsToSelector:@selector(player:beginInterruption:)])
	{
		[delegate player:self beginInterruption:aPlayer];
	}

	DebugLog(@"playing interruption began");
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)aPlayer
{
	if([delegate respondsToSelector:@selector(player:endInterruption:)])
	{
		[delegate player:self endInterruption:aPlayer];
	}

	DebugLog(@"playing interruption ended");
}

@end
