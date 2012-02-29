//
//  AudioQueuePlayer.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 05. 22.
//
//  last update: 10.10.12.
//

#pragma once
#import <Foundation/Foundation.h>

//needs: AudioToolbox.framework
#import <AudioToolbox/AudioToolbox.h>


#define NUMBER_OF_BUFFERS 4	//FIXXX: what's the optimal number of audio queue buffer???
#define BUFFER_DURATION 0.5	//FIXXX: what's the optimal number of buffer duration seconds???

@protocol AudioQueuePlayerDelegate;

//referenced: http://developer.apple.com/iphone/library/documentation/musicaudio/Conceptual/AudioQueueProgrammingGuide/AQPlayback/PlayingAudio.html
@interface AudioQueuePlayer : NSObject {
	
	NSURL* _url;
	
	id<AudioQueuePlayerDelegate> delegate;

	AudioStreamBasicDescription dataFormat;
	AudioQueueRef queue;
	AudioQueueBufferRef* buffers[NUMBER_OF_BUFFERS];
	AudioFileID audioFile;
	UInt32 bufferByteSize;
	SInt64 currentPacket;
	UInt32 numPacketsToRead;
	AudioStreamPacketDescription* packetDescs;

	BOOL isRunning;
	AudioTimeStamp* startTime;
}

/** 
 * initialize audio queue wrapper
 * 
 * @param url
 * @param sampleRate - multiplier for new sampling rate (1.0f for original sampling rate)
 * @returns
 */
- (id)initWithURL:(NSURL*)url 
	 samplingRate:(float)multiplier;
- (id)initWithFilepath:(NSString*)filepath
		  samplingRate:(float)multiplier;
- (id)initWithURL:(NSURL*)url;
- (id)initWithFilepath:(NSString*)filepath;

/**
 * helper function for generating timestamp
 */
+ (AudioTimeStamp)timestampAfterSeconds:(float)seconds;

/**
 * when start time is set by this function,
 * audio queue will start playing at given timestamp
 */
- (void)setStartTime:(AudioTimeStamp*)timestamp;

- (NSTimeInterval)duration;
- (Float64)currentTime;

- (float)volume;
- (void)setVolume:(float)volume;

/**
 * play from start
 * 
 */
- (void)play;

/**
 * @param isResume: play from stopped point or not
 * @param timestamp:
 */
- (void)play:(BOOL)isResume;
- (void)play:(BOOL)isResume 
		from:(AudioTimeStamp*)timestamp;

- (void)seekTo:(Float64)seconds;

- (void)stop:(BOOL)immediate;


@property (readwrite) UInt32 numPacketsToRead;
@property (readwrite) AudioFileID audioFile;
@property (readwrite) AudioStreamPacketDescription* packetDescs;
@property (readwrite) SInt64 currentPacket;
@property (readwrite) AudioQueueRef queue;
@property (readwrite) BOOL isRunning;
@property (readonly) AudioTimeStamp* startTime;
@property (assign) id<AudioQueuePlayerDelegate> delegate;

@end


/**
 * AudioQueuePlayer's delegate
 */
@protocol AudioQueuePlayerDelegate<NSObject>

typedef enum _AudioQueuePlayerAction {
	AudioQueuePlayerStartedPlaying,
	AudioQueuePlayerStoppedPlaying,
} AudioQueuePlayerAction;

/**
 * called when AudioQueuePlayer itself did something (such as 'started playing', 'stopped playing', ...)
 * 
 */
- (void)audioQueuePlayer:(AudioQueuePlayer*)player did:(AudioQueuePlayerAction)what;

@end
