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
//  AVAudioRecorderWrapper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 09. 09.
//
//  last update: 11.09.29.
//

#import "AVAudioRecorderWrapper.h"

#import "FileUtil.h"

#import "Logging.h"


@implementation AVAudioRecorderWrapper

static AVAudioRecorderWrapper* _recorder;

@synthesize quality;
@synthesize channels;
@synthesize sampleRate;
@synthesize delegate;

#pragma mark -
#pragma mark initializers

- (id)init
{
	if((self = [super init]))
	{
		self.quality = DEFAULT_RECORD_QUALITY;
		self.channels = DEFAULT_RECORD_NUM_CHANNELS;
		self.sampleRate = DEFAULT_RECORD_SAMPLING_RATE;
	}
	return self;
}

+ (AVAudioRecorderWrapper*)sharedInstance
{
	@synchronized(self)
	{
		if(!_recorder)
		{
			_recorder = [[AVAudioRecorderWrapper alloc] init];
		}
	}
	return _recorder;
}

+ (void)disposeSharedInstance
{
	@synchronized(self)
	{
		[_recorder release];
		_recorder = nil;
	}
}


#pragma mark -
#pragma mark functions for manipulating

- (BOOL)startRecordingWithFilename:(NSString *)filename
{
	[self stopRecording];
	
	NSString* filepath = [FileUtil pathOfFile:filename withPathType:PathTypeDocument];
	NSURL* fileUrl = [NSURL fileURLWithPath:filepath];
	if(!fileUrl)
	{
		DebugLog(@"file url is nil with filepath: %@", filepath);
		return NO;
	}
	
	DebugLog(@"begin recording: %@", filename);
	
	@synchronized(self)
	{
		NSMutableDictionary* recordSetting = [NSMutableDictionary dictionary];
		[recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
		[recordSetting setValue:[NSNumber numberWithFloat:self.sampleRate] forKey:AVSampleRateKey];
		if(self.channels != 2)	//refer to: http://stackoverflow.com/questions/1141592/iphone-avaudiorecorder-gives-mono-playback-sound-playing-in-just-one-channel
			[recordSetting setValue:[NSNumber numberWithInt:self.channels] forKey:AVNumberOfChannelsKey];
		[recordSetting setValue:[NSNumber numberWithInt:self.quality] forKey:AVEncoderAudioQualityKey];

		NSError* error;
		recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl 
											   settings:recordSetting 
												  error:&error];
		recorder.delegate = self;

		BOOL result = [recorder record];
		if(result)
			[delegate audioRecorderWrapper:self didStartRecordingSuccessfully:YES];
		else
			[delegate audioRecorderWrapper:self didStartRecordingSuccessfully:NO];
		return result;
	}
}

- (BOOL)startRecordingWithFilename:(NSString*)filename duration:(NSTimeInterval)duration
{
	[self stopRecording];
	
	NSString* filepath = [FileUtil pathOfFile:filename withPathType:PathTypeDocument];
	NSURL* fileUrl = [NSURL fileURLWithPath:filepath];
	if(!fileUrl)
	{
		DebugLog(@"file url is nil with filepath: %@", filepath);
		return NO;
	}
	
	DebugLog(@"begin recording: %@", filename);

	@synchronized(self)
	{
		NSMutableDictionary* recordSetting = [NSMutableDictionary dictionary];
		[recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
		[recordSetting setValue:[NSNumber numberWithFloat:self.sampleRate] forKey:AVSampleRateKey]; 
		[recordSetting setValue:[NSNumber numberWithInt:self.channels] forKey:AVNumberOfChannelsKey];
		[recordSetting setValue:[NSNumber numberWithInt:self.quality] forKey:AVEncoderAudioQualityKey];

		NSError* error;
		recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl 
											   settings:recordSetting
												  error:&error];
		recorder.delegate = self;

		BOOL result = [recorder recordForDuration:duration];
		if(result)
			[delegate audioRecorderWrapper:self didStartRecordingSuccessfully:YES];
		else
			[delegate audioRecorderWrapper:self didStartRecordingSuccessfully:NO];
		return result;
	}
}

- (void)stopRecording
{
	@synchronized(self)
	{
		[recorder stop];
		[recorder release];
		recorder = nil;
	}
}

- (NSTimeInterval)currentTime
{
	return [recorder currentTime];
}

- (BOOL)isRecording
{
	return [recorder isRecording];
}


#pragma mark -
#pragma mark av audio recorder delegate functions

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	if(flag)
	{
		DebugLog(@"did finish recording successfully");
		
		[delegate audioRecorderWrapper:self didFinishRecordingSuccessfully:YES];
	}
	else
	{
		DebugLog(@"did finish recording unsuccessfully");

		[delegate audioRecorderWrapper:self didFinishRecordingSuccessfully:NO];
	}
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)aRecorder
{
	DebugLog(@"recording interruption began");

	if([delegate respondsToSelector:@selector(audioRecorderWrapper:beginInterruption:)])
	{
		[delegate audioRecorderWrapper:self 
					 beginInterruption:aRecorder];
	}
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)aRecorder
{
	DebugLog(@"recording interruption ended");

	if([delegate respondsToSelector:@selector(audioRecorderWrapper:endInterruption:)])
	{
		[delegate audioRecorderWrapper:self 
					   endInterruption:aRecorder];
	}
}


#pragma mark -
#pragma mark memory management

- (void)dealloc
{
	[recorder release];
	
	[super dealloc];
}

@end
