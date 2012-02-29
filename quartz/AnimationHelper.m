//
//  AnimationHelper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 25.
//
//  last update: 10.07.21.
//

#import "AnimationHelper.h"

#import "Logging.h"


@implementation AnimationHelper

#pragma mark -
#pragma mark helper functions

+ (void)showAnimationOnView:(UIView*)view 
					 delegate:(id)delegate 
					 function:(SEL)delegateFunction 
						 args:(id)delegateFunctionArgs
					 duration:(float)duration 
					   timing:(UIViewAnimationCurve)animationCurve 
						 type:(NSString*)type 
					  subtype:(NSString*)subtype 
{
	CATransition* animation = [CATransition animation];
	[animation setDelegate:delegate];
	[animation setDuration:duration];
	[animation setTimingFunction:(CAMediaTimingFunction*)animationCurve];	//UIViewAnimationCurveEaseInOut, UIViewAnimationCurveEaseIn, UIViewAnimationCurveEaseOut, UIViewAnimationCurveLinear
	[animation setType:type];	//kCATransitionFade, kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal
	[animation setSubtype:subtype];	//kCATransitionFromRight, kCATransitionFromLeft, kCATransitionFromTop, kCATransitionFromBottom
	
	//do something (ex: exchange subviews, ...)
	if(delegateFunctionArgs)
		[delegate performSelector:delegateFunction withObject:delegateFunctionArgs];
	else
		[delegate performSelector:delegateFunction];
	
	[view.layer addAnimation:animation forKey:@"transitionViewAnimation"];
}

@end
