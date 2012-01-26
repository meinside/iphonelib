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
//  UIButton+Vibratable.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 01. 26.
//
//  last update: 12.01.26.
//

#import "UIButton+Vibratable.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0

@implementation UIButton (UIButtonVibratable)

- (BOOL)isAnimating
{
	//test
	NSLog(@"animation keys = %@", [self.layer animationKeys]);

	return [[self.layer animationKeys] count] > 0;
}

//referenced: http://stackoverflow.com/questions/6604356/ios-icon-jiggle-algorithm
- (void)toggleVibration
{
	@synchronized(self)
	{
		if([self isAnimating])
		{
			[self.layer removeAllAnimations];
			self.transform = CGAffineTransformIdentity;
		}
		else
		{
			NSInteger randomInt = arc4random()%500;
			float r = (randomInt/500.0)+0.5;
			
			CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( (kAnimationRotateDeg * -1.0) - r ));
			CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg + r ));
			
			self.transform = leftWobble;  // starting point

			[self.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
			
			[UIView animateWithDuration:0.1
								  delay:0
								options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
							 animations:^{
								 [UIView setAnimationRepeatCount:NSNotFound];
								 self.transform = rightWobble; }
							 completion:nil];
		}
	}
}

@end
