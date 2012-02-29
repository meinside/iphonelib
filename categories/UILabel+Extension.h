//
//  UILabel+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 7. 16.
//
//  last update: 10.11.29.
//

#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum _UILabelResizeResult{
	UILabelResizeFailed = -1,
	UILabelResizedNoChange = 0,
	UILabelResized = 1,
} UILabelResizeResult;


@interface UILabel (UILabelExtension)

//align text to top
- (UILabelResizeResult)alignToTop;

//enlarge height of this label to keep current text and font size
- (UILabelResizeResult)enlargeHeightToKeepFontSize;

//resize font size to keep current text and label size
- (UILabelResizeResult)resizeFontSizeToKeepCurrentRect:(CGFloat)initialFontSize;

@end
