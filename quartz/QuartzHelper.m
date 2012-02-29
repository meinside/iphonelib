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
