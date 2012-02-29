//
//  BadgeLabel.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 1. 21.
//
//  last update: 11.04.28.
//

#import <UIKit/UIKit.h>

#define BADGE_VERTICAL_MARGIN 1.8f
#define BADGE_HORIZONTAL_MARGIN 4.5f


@interface BadgeLabel : UIView {
	NSString* badgeString;
}

@property (nonatomic, copy, setter=changeBadgeString:) NSString* badgeString;

@end
