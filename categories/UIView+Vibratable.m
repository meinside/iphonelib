//
//  UIView+Vibratable.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 01. 26.
//
//  last update: 12.04.12.
//

#import "UIView+Vibratable.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0

@implementation UIView (UIViewVibratable)

- (BOOL)isAnimating
{
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
