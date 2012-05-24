//
//  UIView+Animatable.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 05. 24.
//
//  last update: 12.05.24.
//

#pragma once

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#warning Do not use this if deployment target is lower than 4.0
#endif

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>	//needs: QurtzCore.framework

@interface UIView (UIViewAnimatable)

- (BOOL)isAnimating;

- (void)toggleBouncing;
- (void)toggleVibration;

@end
