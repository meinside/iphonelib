//
//  BadgeableButton.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 1. 21.
//
//  last update: 11.04.28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BadgeLabel.h"


@interface BadgeableButton : UIButton {
	BadgeLabel* badgeLabel;
}

@property (nonatomic, copy, setter=changeBadgeString:) NSString* badgeString;

@end
