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
//  UILabel+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 7. 16.
//
//  last update: 10.09.13.
//

#import "UILabel+Extension.h"

#import "Logging.h"


@implementation UILabel (UILabelExtension)

- (void)alignToTop
{
	CGRect rect = [self textRectForBounds:self.bounds limitedToNumberOfLines:999];

	CGRect newRect = self.frame;
	newRect.size.height = rect.size.height;

	self.frame = newRect;
}

- (UILabelResizeResult)resizeToFitString:(NSString*)newString withFontSize:(CGFloat)initialFontSize
{
	CGFloat originalLabelHeight = self.frame.size.height;
	CGFloat labelHeight;
	UIFont* font = self.font;

	for(CGFloat f = initialFontSize; f > self.minimumFontSize; f -= 2.0f)
	{
		font = [font fontWithSize:f];
		CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
		CGSize labelSize = [newString sizeWithFont:font 
								 constrainedToSize:constraintSize 
									 lineBreakMode:UILineBreakModeWordWrap];

		labelHeight = labelSize.height;
		if(labelHeight <= originalLabelHeight)
			break;
	}

	self.font = font;
	self.text = newString;
	
	if(labelHeight == originalLabelHeight)
		return UILabelResizedNoChange;
	else if(labelHeight < originalLabelHeight)
		return UILabelResized;
	else
		return UILabelResizeFailed;
}

@end
