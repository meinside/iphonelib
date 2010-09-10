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
//  AVAudioPlayerWrapper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 08. 22.
//
//  last update: 10.09.09.
//

#pragma once
#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "FileUtil.h"

@protocol AVAudioPlayerWrapperDelegate;

@interface AVAudioPlayerWrapper : NSObject <AVAudioPlayerDelegate> {
	
	AVAudioPlayer* player;
	
	NSMutableArray* filenames;
	NSTimer* playTimer;
	
	float gap;
	
	NSString* lastPlayedFilename;
	
	id<AVAudioPlayerWrapperDelegate> delegate;
	
	BOOL startAfterEachFinish;
	
	PathType filePathType;
}

+ (AVAudioPlayerWrapper*)sharedInstance;
+ (void)disposeSharedInstance;

- (BOOL)playSound:(NSString*)filename;
- (BOOL)playSound:(NSString *)filename pathType:(PathType)pathType;

/**
 * start a batch play of multiple sound files
 * 
 * @someGap: gap between each sound play
 * @startAfterPreviousSoundsFinish: whether to start next sound after previous one's complete finish, or not
 * @someDelay: start this batch play after someDelay
 */
- (void)playSounds:(NSArray*)someFilenames withGap:(float)someGap afterEachFinish:(BOOL)startAfterPreviousSoundsFinish delay:(float)someDelay;
- (void)playSounds:(NSArray*)someFilenames pathType:(PathType)pathType withGap:(float)someGap afterEachFinish:(BOOL)startAfterPreviousSoundsFinish delay:(float)someDelay;

- (void)stopSound;

- (void)setDelegate:(id<AVAudioPlayerWrapperDelegate>)newDelegate;

@end

@protocol AVAudioPlayerWrapperDelegate <NSObject>

- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper willStartPlayingFilename:(NSString*)filename;

- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper didStartPlayingFilename:(NSString*)filename;

- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper didFinishPlayingFilename:(NSString*)filename;

- (void)audioPlayerWrapper:(AVAudioPlayerWrapper*)wrapper didFinishPlayingSuccessfully:(BOOL)success;

@end
