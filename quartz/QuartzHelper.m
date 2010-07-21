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
//  QuartzHelper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 12.
//
//  last update: 10.07.21.
//

#import "QuartzHelper.h"

#import "Logging.h"


@implementation QuartzHelper

#pragma mark -
#pragma mark getter functions

+ (CGContextRef)currentContext
{
	return UIGraphicsGetCurrentContext();
}

+ (CGColorRef)createColorRefWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat values[] = {r, g, b, a};
	CGColorRef color = CGColorCreate(rgb, values);
	
	return color;
}

#pragma mark -
#pragma mark setter functions

+ (void)setFontOfContext:(CGContextRef)context withFontName:(NSString*)fontName fontSize:(CGFloat)fontSize textEncoding:(CGTextEncoding)textEncoding
{
	CGContextSelectFont(context, [fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, textEncoding);
}

+ (void)setFillColorOfContext:(CGContextRef)context withColor:(CGColorRef)color
{
	CGContextSetFillColorWithColor(context, color);
}

+ (void)setFillColorOfContext:(CGContextRef)context withR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a
{
	CGContextSetRGBFillColor(context, r, g, b, a);
}

+ (void)setStrokeColorOfContext:(CGContextRef)context withColor:(CGColorRef)color
{
	CGContextSetStrokeColorWithColor(context, color);	
}

+ (void)setStrokeColorOfContext:(CGContextRef)context withR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a
{
	CGContextSetRGBStrokeColor(context, r, g, b, a);
}

+ (void)setCharacterSpacingOfContext:(CGContextRef)context withSpacing:(CGFloat)spacing
{
	CGContextSetCharacterSpacing(context, spacing);	
}

+ (void)setTextDrawingModeOfContext:(CGContextRef)context withMode:(CGTextDrawingMode)mode
{
	CGContextSetTextDrawingMode(context, mode);
}

+ (NSArray*)allFontNames
{
	NSMutableArray* fontNames = [NSMutableArray array];

	for(NSString* familyName in [UIFont familyNames])
	{
		DebugLog(@"family: %@", familyName);

		for(NSString* fontName in [UIFont fontNamesForFamilyName:familyName])
		{
			DebugLog(@"font: %@", fontName);

			[fontNames addObject:fontName];
		}
	}

	return fontNames;
}

#pragma mark -
#pragma mark factory functions

+ (CGMutablePathRef)createLinePathWithPoints:(CGPoint*)points numberOfPoints:(NSInteger)count closePath:(BOOL)close
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	//do something
	for(int index = 0; index < count; index ++)
	{	
		if(index == 0)
		{
			CGPathMoveToPoint(path, nil, points[index].x, points[index].y);
		}
		else
		{
			CGPathAddLineToPoint(path, nil, points[index].x, points[index].y);
		}
	}

	//close path if needed
	if(close)
		CGPathCloseSubpath(path);
	
	return path;
}

@end
