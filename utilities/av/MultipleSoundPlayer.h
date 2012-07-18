//
//  MultipleSoundPlayer.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 07. 18.
//
//  last update: 12.07.18.
//

#pragma once
#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "FileUtil.h"

@protocol MultipleSoundPlayerDelegate;

@interface MultipleSoundPlayer : NSObject <AVAudioPlayerDelegate> {
	
	float gap;
	float volume;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	float rate;
#endif

	BOOL startAfterEachFinish;
}

- (id)init;
+ (MultipleSoundPlayer*)sharedInstance;
+ (void)disposeSharedInstance;

- (BOOL)playSoundWithFilepath:(NSString*)filepath;
- (BOOL)playSound:(NSString*)filename 
	 withPathType:(PathType)pathType;

/**
 * start a batch play of multiple sound files
 * 
 * @someGap: gap between each sound play
 * @startAfterPreviousSoundsFinish: whether to start next sound after previous one's complete finish, or not
 * @someDelay: start this batch play after someDelay
 */
- (void)playSoundFiles:(NSArray*)someFilepaths 
			   withGap:(float)someGap 
	   afterEachFinish:(BOOL)startAfterPreviousSoundsFinish 
				 delay:(float)someDelay;
- (void)playSounds:(NSArray*)someFilenames 
		  pathType:(PathType)pathType 
		   withGap:(float)someGap 
   afterEachFinish:(BOOL)startAfterPreviousSoundsFinish 
			 delay:(float)someDelay;

- (void)stopSound;

- (NSTimeInterval)getCurrentTime;
- (void)setCurrentTime:(NSTimeInterval)newCurrentTime;

- (float)currentVolume;
- (void)setVolume:(float)newVolume;

- (BOOL)isPlaying;

@property (retain) NSMutableArray* filepaths;
@property (retain, nonatomic) AVAudioPlayer* player;
@property (retain) NSTimer* playTimer;
@property (copy) NSString* lastPlayedFilepath;

@property (assign) id<MultipleSoundPlayerDelegate> delegate;
@property (getter=getCurrentTime, setter=setCurrentTime:) NSTimeInterval currentTime;
@property (getter=currentVolume, setter=setVolume:) float volume;
@property (readonly, getter=isPlaying) BOOL playing;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
@property (getter=getCurrentRate, setter=setCurrentRate:) float rate;
#endif

@end

@protocol MultipleSoundPlayerDelegate <NSObject>

- (void)player:(MultipleSoundPlayer*)wrapper willStartPlayingFilepath:(NSString*)filepath;
- (void)player:(MultipleSoundPlayer*)wrapper didStartPlayingFilepath:(NSString*)filepath;
- (void)player:(MultipleSoundPlayer*)wrapper didFinishPlayingFilepath:(NSString*)filepath;
- (void)player:(MultipleSoundPlayer*)wrapper didFinishPlayingSuccessfully:(BOOL)success;	//called when all sounds finish playing

@optional

- (void)player:(MultipleSoundPlayer*)wrapper beginInterruption:(AVAudioPlayer*)player;
- (void)player:(MultipleSoundPlayer*)wrapper endInterruption:(AVAudioPlayer*)player;

@end
