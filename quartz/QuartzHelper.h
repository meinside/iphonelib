//
//  QuartzHelper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 12.
//
//  last update: 10.11.29.
//

#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//needs: CoreGraphics.framework


@interface QuartzHelper : NSObject {

}

+ (CGContextRef)currentContext;
+ (CGColorRef)createColorRefWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;
+ (void)setFontOfContext:(CGContextRef)context withFontName:(NSString*)fontName fontSize:(CGFloat)fontSize textEncoding:(CGTextEncoding)textEncoding;
+ (void)setFillColorOfContext:(CGContextRef)context withColor:(CGColorRef)color;
+ (void)setFillColorOfContext:(CGContextRef)context withR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;
+ (void)setStrokeColorOfContext:(CGContextRef)context withColor:(CGColorRef)color;
+ (void)setStrokeColorOfContext:(CGContextRef)context withR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;
+ (void)setCharacterSpacingOfContext:(CGContextRef)context withSpacing:(CGFloat)spacing;
+ (void)setTextDrawingModeOfContext:(CGContextRef)context withMode:(CGTextDrawingMode)mode;
+ (CGMutablePathRef)createLinePathWithPoints:(CGPoint*)points numberOfPoints:(NSInteger)count closePath:(BOOL)close;

+ (NSArray*)allFontNames;

@end
