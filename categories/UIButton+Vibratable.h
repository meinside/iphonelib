//
//  UIButton+Vibratable.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 01. 26.
//
//  last update: 12.01.26.
//

#pragma once

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#warning Do not use this if deployment target is lower than 4.0
#endif

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>	//needs: QurtzCore.framework

@interface UIButton (UIButtonVibratable)

- (BOOL)isAnimating;
- (void)toggleVibration;

@end
