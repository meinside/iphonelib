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
