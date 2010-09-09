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
//  AVAudioRecorderWrapper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 09. 09.
//
//  last update: 10.09.09.
//

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

+ (AVAudioRecorderWrapper*)sharedInstance;
+ (void)disposeSharedInstance;

- (BOOL)startRecordingWithFilename:(NSString *)filename;
- (BOOL)startRecordingWithFilename:(NSString*)filename duration:(NSTimeInterval)duration;
- (void)stopRecording;

- (NSTimeInterval)currentTime;
- (BOOL)isRecording;

- (void)setDelegate:(id<AVAudioRecorderWrapperDelegate>)newDelegate;

@property (nonatomic, assign) AVAudioQuality quality;
@property (nonatomic, assign) int channels;
@property (nonatomic, assign) float sampleRate;

@end

@protocol AVAudioRecorderWrapperDelegate <NSObject>

- (void)audioRecorderWrapper:(AVAudioRecorderWrapper*)wrapper didStartRecordingSuccessfully:(BOOL)success;

- (void)audioRecorderWrapper:(AVAudioRecorderWrapper*)wrapper didFinishRecordingSuccessfully:(BOOL)success;

@end

