//
//  UIImage+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 3. 5.
//
//  last update: 10.11.29.
//

#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum _FilterType {
	FilterType1x1,	/* FilterNegative, FilterLighter, FilterDarker, FilterContrastMore, FilterContrastLess */
	FilterType3x3,	/* FilterSmoothen, FilterSharpen, FilterSharpenStrong, FilterFindEdges, FilterContour, FilterEdgeDetect, FilterEdgeDetectSoft, FilterEmboss, FilterNegative3x3, FilterLighter3x3, FilterDarker3x3, FilterContrastMore3x3, FilterContrastLess3x3 */
	FilterType5x5,	/* FilterBlur */
	FilterTypeIC,	/* FilterMonochrome, FilterGBR2RGB, FilterBRG2RGB, FilterWhiteAlpha */
} FilterType;

@interface UIImage (UIImageExtension) 

#pragma mark -
#pragma mark functions for applying various filters

/**
 * apply given filter to this image and return it
 * 
 * @filter: filter from GraphicFilter.h
 * @type: one of FilterType1x1, FilterType3x3, FilterType5x5, FilterTypeIC
 * 
 * @return: filter-applied image
 */
- (UIImage*)filteredImageWithFilter:(void*)filter 
						 filterType:(FilterType)type;

@end
