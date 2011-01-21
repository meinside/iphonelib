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
//  BadgeableButton.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 1. 21.
//
//  last update: 11.01.21.
//

#import "BadgeLabel.h"

#import "Logging.h"


@implementation BadgeLabel

@synthesize badgeString;

- (void)drawRect:(CGRect)rect
{
	if([badgeString length] > 0)
	{
		DebugLog(@"drawing badge string: %@", badgeString);
		
		CGContextRef ref = UIGraphicsGetCurrentContext();

		UIFont* font = [UIFont systemFontOfSize:8.0];
		
		CGRect buttonRect = self.frame;
		CGSize textSize = [badgeString sizeWithFont:font];
		CGRect badgeRect = CGRectMake(buttonRect.size.width - (textSize.width + BADGE_HORIZONTAL_MARGIN * 2), BADGE_VERTICAL_MARGIN * 2, textSize.width, textSize.height);
		CGRect badgeBgRect = CGRectMake(buttonRect.size.width - (textSize.width + BADGE_HORIZONTAL_MARGIN * 3), BADGE_VERTICAL_MARGIN, textSize.width + BADGE_HORIZONTAL_MARGIN * 2, textSize.height + BADGE_VERTICAL_MARGIN * 2);
		
		//gradient (referenced: http://efreedom.com/Question/1-2985359/Fill-Path-Gradient-DrawRect )
		size_t numLocations = 2;
		CGFloat locations[2] = {0.0, 0.9};
		CGFloat components[8] = {
			1.0, 0.25, 0.25, 0.9,	//start color
			0.4, 0.0, 0.0, 1.0,	//end color
			};
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, numLocations);

		//fill gradient color
		CGContextSaveGState(ref);
		CGContextAddEllipseInRect(ref, badgeBgRect);
		CGContextClip(ref);
		CGContextDrawLinearGradient(ref, gradient, CGPointMake(CGRectGetMidX(badgeBgRect), CGRectGetMinY(badgeBgRect)), CGPointMake(CGRectGetMidX(badgeBgRect), CGRectGetMaxY(badgeBgRect)), 0);
		CGContextRestoreGState(ref);
		CGGradientRelease(gradient);
		CGColorSpaceRelease(colorspace);
		
		//stroke border and text
		CGContextSetAllowsAntialiasing(ref, YES);
		CGContextSetShouldAntialias(ref, YES);
		CGContextSetLineWidth(ref, 1.1);
		CGContextSetRGBStrokeColor(ref, 1.0f, 1.0f, 1.0f, 1.0f);
		CGContextSetTextDrawingMode(ref, kCGTextFillStroke);
		CGContextStrokeEllipseInRect(ref, badgeBgRect);
		[badgeString drawInRect:badgeRect withFont:font];
	}
}

- (void)changeBadgeString:(NSString *)str
{
	[badgeString release];
	badgeString = [str copy];

	[self setNeedsLayout];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[badgeString release];

    [super dealloc];
}


@end
