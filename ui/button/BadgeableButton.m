//
//  BadgeableButton.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 1. 21.
//
//  last update: 11.01.21.
//

#import "BadgeableButton.h"


@implementation BadgeableButton

@synthesize badgeString;

- (void)changeBadgeString:(NSString *)str
{
	//XXX:
	//badges drawn in drawRect: of image UIButtons are covered back with its images,
	//so I added a subview instead of overriding drawRect:

	if(!badgeLabel)
	{
		badgeLabel = [[BadgeLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		badgeLabel.backgroundColor = [UIColor clearColor];
		badgeLabel.userInteractionEnabled = NO;
		[self addSubview:badgeLabel];
	}

	badgeLabel.badgeString = str;
}

- (void)dealloc
{
	[badgeLabel release];
	[super dealloc];
}

@end
