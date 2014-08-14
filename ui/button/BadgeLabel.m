//
//  BadgeableButton.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 1. 21.
//
//  last update: 2014.08.14.
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
		//FIX - sizeWithFont: deprecated in iOS 7
//		CGSize textSize = [badgeString sizeWithFont:font];
		CGSize textSize = [badgeString sizeWithAttributes:@{NSFontAttributeName: font}];
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

		//FIX - drawInRect:withFont: deprecated in iOS 7
//		[badgeString drawInRect:badgeRect withFont:font];
		[badgeString drawInRect:badgeRect
				 withAttributes:@{
								  NSFontAttributeName: font,
								  }];
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
