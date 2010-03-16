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
//  AVUtil.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 10.02.03.
//

#pragma once
#import <Foundation/Foundation.h>

//needs: AVFoundation.framework
#import <AVFoundation/AVAudioSession.h>

//needs: AudioToolbox.framework
#import <AudioToolbox/AudioToolbox.h>


@interface AVUtil : NSObject {

}

+ (BOOL)setActive:(BOOL)activeOrNot;

/* @param category
 * (from: http://developer.apple.com/iphone/library/documentation/AVFoundation/Reference/AVAudioSession_ClassReference/Reference/Reference.html#//apple_ref/doc/constant_group/Audio_Session_Categories )
 *
 * AVAudioSessionCategoryAmbient:
 * For an application in which sound playback is nonprimary:
 * your application can be used successfully with the sound turned off. 
 * This category is also appropriate for “play along” style applications, 
 * such as a virtual piano that a user plays over iPod audio. 
 * When you use this category, other audio, such as from the iPod application, mixes with your audio. 
 * Your audio is silenced by screen locking and by the Ring/Silent switch.
 *
 * AVAudioSessionCategorySoloAmbient:
 * The default category; used unless you set a category with the setCategory:error: method.
 * This category silences audio from other applications, such as the iPod. 
 * Your audio is silenced by screen locking and by the Ring/Silent switch.
 * 
 * AVAudioSessionCategoryPlayback:
 * For playing recorded music or other sounds that are central to the successful use of your application. 
 * This category silences audio from other applications, such as the iPod. 
 * You can, however, modify this category to allow mixing by using the kAudioSessionProperty_OverrideCategoryMixWithOthers property. 
 * Your audio continues with the Ring/Silent switch set to silent and with the screen locked.
 * 
 * AVAudioSessionCategoryRecord:
 * For recording audio; this category silences playback audio. 
 * Recording continues with the screen locked.
 * 
 * AVAudioSessionCategoryPlayAndRecord:
 * For recording and playback of audio—simultaneous or not—such as for a VOIP (voice over IP) application. 
 * This category silences audio from other applications, such as the iPod. 
 * You can, however, modify this category to allow mixing by using the kAudioSessionProperty_OverrideCategoryMixWithOthers property. 
 * Your audio continues with the Ring/Silent switch set to silent and with the screen locked.
 * 
 * AVAudioSessionCategoryAudioProcessing:
 * For using an audio hardware codec or signal processor while not playing or recording audio. 
 * Use this category, for example, when performing offline audio format conversion.
 */
+ (BOOL)setAudioSessionCategory:(NSString*)category;

+ (NSTimeInterval)estimatedDurationOfAudioFile:(NSString*)filepath;

@end
