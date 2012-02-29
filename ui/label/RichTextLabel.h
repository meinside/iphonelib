//
//  RichTextLabel.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 09. 08.
//
//  last update: 11.03.31.
//

#pragma once
#import <UIKit/UIKit.h>

typedef enum _TextAlign{
	TextAlignLeft = 1,
	TextAlignCenter = 2,
	TextAlignRight = 3,
} TextAlign;

#define RL_DEFAULT_BG_COLOR @"transparent"
#define RL_DEFAULT_MARGIN 0
#define RL_DEFAULT_PADDING 0
#define RL_DEFAULT_FONT_SIZE 16
#define RL_DEFAULT_LETTER_SPACING 2
#define RL_DEFAULT_LINE_HEIGHT 2
#define RL_DEFAULT_FONT_FAMILY @"Helvetica"
#define RL_DEFAULT_TEXT_ALIGN TextAlignCenter


@interface RichTextLabel : UIWebView {

	NSString* bgColor;	//ex: @"red", @"black", @"transparent", ...
	
	int margin, padding;
	int fontSize, letterSpacing, lineHeight;
	
	NSString* html;	//ex: @"<font color='#FF0000'>warning</font>"
	
	NSString* fontFamily;	//ex: @"Helvetica"
	
	TextAlign align;
}

//ex: @"<b><font color=\"black\" face='Helvetica-Bold'>Black</font> <font color=\"#3399FF\" face='Helvetica'>and</font> <font color=\"black\" face='Helvetica-Bold'>Bold</font></b>"
- (void)changeText:(NSString*)htmlString;

@property (nonatomic, copy, setter=changeText:) NSString* html;

@property (nonatomic, copy) NSString* bgColor;
@property (nonatomic, assign) int margin;
@property (nonatomic, assign) int padding;
@property (nonatomic, assign) int fontSize;
@property (nonatomic, assign) int letterSpacing;
@property (nonatomic, assign) int lineHeight;
@property (nonatomic, copy) NSString* fontFamily;
@property (nonatomic, assign) TextAlign align;

@end
