//
//  UIView+Animatable.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 05. 24.
//
//  last update: 12.05.24.
//

#import "UIView+Animatable.h"

#define kJumpFactor 0.5

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0

@implementation UIView (UIViewAnimatable)

- (BOOL)isAnimating
{
	return [[self.layer animationKeys] count] > 0;
}

//referenced: http://stackoverflow.com/questions/6915702/creating-itunes-store-style-jump-animation
- (void)toggleBouncing
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
			CGMutablePathRef path = CGPathCreateMutable();
			CGPoint startPoint = self.layer.position;
			CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
			CGPathAddLineToPoint(path,
								 NULL,
								 startPoint.x, startPoint.y - self.frame.size.height * kJumpFactor);
			CGPathAddLineToPoint(path,
								 NULL,
								 startPoint.x, startPoint.y);
			CAKeyframeAnimation* jumpAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
			jumpAnimation.timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
			jumpAnimation.path = path;
			CGPathRelease(path);

			jumpAnimation.repeatCount = NSNotFound;	//repeat until toggling
			jumpAnimation.duration = 1;
			jumpAnimation.delegate = self;
			[jumpAnimation setValue:self.layer 
							 forKey:@"animatedLayer"];

			[self.layer addAnimation:jumpAnimation 
							  forKey:@"jumpAnimation"];
		}
	}
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
