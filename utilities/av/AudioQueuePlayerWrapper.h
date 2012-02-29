//
//  AudioQueuePlayerWrapper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 28.
//
//  last update: 10.10.12.
//

#pragma once
#import <Foundation/Foundation.h>

#import "AudioQueuePlayer.h"

#import "FileUtil.h"


@protocol AudioQueuePlayerWrapperDelegate;

@interface AudioQueuePlayerWrapper : NSObject<AudioQueuePlayerDelegate> {

	NSURL* currentURL;
	float currentSamplingRateMultiplier;
	
	AudioQueuePlayer* player;
	
	id<AudioQueuePlayerWrapperDelegate> delegate;
	
	Float64 lastTime;
	Float64 lastSeekTime;
	
	BOOL initialized;
}

/**
 * initializers
 */
- (id)init;
- (id)initWithFilename:(NSString*)filename andSamplingRateMultiplier:(float)multiplier;
- (id)initWithFilename:(NSString*)filename pathType:(PathType)pathType andSamplingRateMultiplier:(float)multiplier;
- (BOOL)isInitialized;

/**
 * using singleton pattern
 */
+ (AudioQueuePlayerWrapper*)sharedInstance;

/**
 * dispose it when unused
 */
+ (void)disposeSharedInstance;


/**
 * set audio file with sampling rate multiplier
 */
- (void)setFileNamed:(NSString*)filename withSamplingRateMultiplier:(float)multiplier;
- (void)setFileNamed:(NSString*)filename pathType:(PathType)pathType withSamplingRateMultiplier:(float)multiplier;

/**
 * change samping rate (can be changed while playing)
 */
- (void)changeSamplingRateMultiplierTo:(float)multiplier;


/**
 * get current time (sampling rate applied)
 */
- (Float64)currentTime;

/**
 * check if it's playing or not
 */
- (BOOL)isPlaying;

/**
 * get duration of audio file (sampling rate applied)
 */
- (NSTimeInterval)duration;


/**
 * start playing
 */
- (void)play;

/**
 * stop playing
 */
- (void)stop;

/**
 * resume playing
 */
- (void)resume;

/**
 * jump to given timeline position
 */
- (void)seekTo:(Float64)seconds;

/**
 * jump to given timeline position (based on original file's timeline)
 */
- (void)seekToOriginal:(Float64)seconds;

@property (assign) id<AudioQueuePlayerWrapperDelegate> delegate;

@end


/**
 * AudioQueuePlayerWrapper's delegate
 */
@protocol AudioQueuePlayerWrapperDelegate<NSObject>

/**
 * called when AudioQueuePlayerWrapper stopped playing
 * 
 */
- (void)audioQueuePlayerWrapper:(AudioQueuePlayerWrapper*)wrapper did:(AudioQueuePlayerAction)what;

@end
