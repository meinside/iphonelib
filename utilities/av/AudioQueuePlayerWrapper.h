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