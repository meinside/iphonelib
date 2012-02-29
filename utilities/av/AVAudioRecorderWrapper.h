//
//  AVAudioRecorderWrapper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 09. 09.
//
//  last update: 11.09.29.
//

#pragma once
#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>


#define DEFAULT_RECORD_QUALITY AVAudioQualityHigh
#define DEFAULT_RECORD_NUM_CHANNELS 2
#define DEFAULT_RECORD_SAMPLING_RATE 44100.0f

@protocol AVAudioRecorderWrapperDelegate;

@interface AVAudioRecorderWrapper : NSObject <AVAudioRecorderDelegate> {

	AVAudioRecorder* recorder;
	
	AVAudioQuality quality;
	int channels;
	float sampleRate;
	
	id<AVAudioRecorderWrapperDelegate> delegate;
}

- (id)init;
+ (AVAudioRecorderWrapper*)sharedInstance;
+ (void)disposeSharedInstance;

- (BOOL)startRecordingWithFilename:(NSString *)filename;
- (BOOL)startRecordingWithFilename:(NSString*)filename duration:(NSTimeInterval)duration;
- (void)stopRecording;

- (NSTimeInterval)currentTime;
- (BOOL)isRecording;

@property (nonatomic, assign) AVAudioQuality quality;
@property (nonatomic, assign) int channels;
@property (nonatomic, assign) float sampleRate;
@property (assign) id<AVAudioRecorderWrapperDelegate> delegate;

@end

@protocol AVAudioRecorderWrapperDelegate <NSObject>

- (void)audioRecorderWrapper:(AVAudioRecorderWrapper*)wrapper didStartRecordingSuccessfully:(BOOL)success;
- (void)audioRecorderWrapper:(AVAudioRecorderWrapper*)wrapper didFinishRecordingSuccessfully:(BOOL)success;

@optional

- (void)audioRecorderWrapper:(AVAudioRecorderWrapper*)wrapper beginInterruption:(AVAudioRecorder*)aRecorder;
- (void)audioRecorderWrapper:(AVAudioRecorderWrapper*)wrapper endInterruption:(AVAudioRecorder*)aRecorder;

@end

