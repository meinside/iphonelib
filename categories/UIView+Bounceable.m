//
//  UIView+Bounceable.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 12. 05. 10.
//
//  last update: 12.05.10.
//

#import "UIView+Bounceable.h"

#define kJumpFactor 0.5

@implementation UIView (UIViewBounceable)

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

@end
