//
//  AnimationHelper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 25.
//
//  last update: 10.11.29.
//

#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//needs: QuartzCore.framework
#import <QuartzCore/QuartzCore.h>


@interface AnimationHelper : NSObject {

}

+ (void)showAnimationOnView:(UIView*)view 
				   delegate:(id)delegate 
				   function:(SEL)delegateFunction 
					   args:(id)delegateFunctionArgs
				   duration:(float)duration 
					 timing:(UIViewAnimationCurve)animationCurve 
					   type:(NSString*)type 
					subtype:(NSString*)subtype;

@end
