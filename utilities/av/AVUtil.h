//
//  AVUtil.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 10.07.21.
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
+ (NSTimeInterval)estimatedDurationOfAudioFileurl:(NSURL*)url;

@end
