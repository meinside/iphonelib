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
