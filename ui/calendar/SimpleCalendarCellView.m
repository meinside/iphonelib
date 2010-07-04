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
//  SimpleCalendarCellView.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 10.07.04.
//

#import "SimpleCalendarCellView.h"

#import "QuartzHelper.h"

#import "Logging.h"


@implementation SimpleCalendarCellView

#pragma mark -
#pragma mark SimpleCalendarCellVies

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		cellType = CalendarCellTypeNone; oldCellType = cellType;
		cellStatus = CalendarCellStatusNone; oldCellStatus = cellStatus;
		day = 0; oldDay = day;

		//background colors
		bgColor = [QuartzHelper createColorRefWithR:CELL_BG_COLOR_R 
												  G:CELL_BG_COLOR_G 
												  B:CELL_BG_COLOR_B 
												  A:1.0f];
		bgColorExtra = [QuartzHelper createColorRefWithR:CELL_EXTRA_BG_COLOR_R 
													   G:CELL_EXTRA_BG_COLOR_G 
													   B:CELL_EXTRA_BG_COLOR_B 
													   A:1.0f];
		bgColorSelected = [QuartzHelper createColorRefWithR:CELL_SELECTED_BG_COLOR_R 
														  G:CELL_SELECTED_BG_COLOR_G 
														  B:CELL_SELECTED_BG_COLOR_B 
														  A:1.0f];
		
		//foreground colors
		fgColor = [QuartzHelper createColorRefWithR:CELL_FG_COLOR_R 
												  G:CELL_FG_COLOR_G 
												  B:CELL_FG_COLOR_B 
												  A:1.0f];
		fgColorExtra = [QuartzHelper createColorRefWithR:CELL_EXTRA_FG_COLOR_R 
													   G:CELL_EXTRA_FG_COLOR_G 
													   B:CELL_EXTRA_FG_COLOR_B 
													   A:1.0f];
		fgColorSelected = [QuartzHelper createColorRefWithR:CELL_SELECTED_FG_COLOR_R 
														  G:CELL_SELECTED_FG_COLOR_G 
														  B:CELL_SELECTED_FG_COLOR_B 
														  A:1.0f];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	CGContextRef context = [QuartzHelper currentContext];
	
	//fill background color
	if(cellStatus == CalendarCellStatusSelected)
	{
		[QuartzHelper setFillColorOfContext:context withColor:bgColorSelected];
	}
	else if(cellType != CalendarCellTypeCurrentMonth)
	{
		[QuartzHelper setFillColorOfContext:context withColor:bgColorExtra];
	}
	else
	{
		[QuartzHelper setFillColorOfContext:context withColor:bgColor];
	}
	CGContextFillRect(context, rect);
	
	//draw border lines
	[QuartzHelper setStrokeColorOfContext:context 
									withR:CELL_BORDER_LINE_COLOR_R 
										G:CELL_BORDER_LINE_COLOR_G 
										B:CELL_BORDER_LINE_COLOR_B 
										A:1.0f];
	CGContextStrokeRect(context, rect);

	//draw text
	if(day > 0)
	{
		[QuartzHelper setFillColorOfContext:context withColor:fgColor];
		[[NSString stringWithFormat:@"%02d", day] drawInRect:rect
													withFont:[UIFont fontWithName:DAY_FONT size:(rect.size.width / DIVIDER_FOR_DAY_FONT_SIZE)] 
											   lineBreakMode:UILineBreakModeWordWrap 
												   alignment:UITextAlignmentRight];
	}
}


#pragma mark -
#pragma mark cell-manipulating functions

- (void)setCellType:(CalendarCellType)newCellType
{
	oldCellType = cellType;
	cellType = newCellType;
	
	if(oldCellType != cellType)
		[self setNeedsDisplay];
}

- (void)setCellStatus:(CalendarCellStatus)newCellStatus
{
	oldCellStatus = cellStatus;
	cellStatus = newCellStatus;
	
	if(oldCellStatus != cellStatus)
		[self setNeedsDisplay];
}

- (void)setDay:(uint)newDay
{
	oldDay = day;
	day = newDay;
	
	if(oldDay != day)
		[self setNeedsDisplay];
}

- (void)setCellType:(CalendarCellType)newCellType 
		 cellStatus:(CalendarCellStatus)newCellStatus 
				day:(uint)newDay
{
	oldCellType = cellType;
	cellType = newCellType;
	
	oldCellStatus = cellStatus;
	cellStatus = newCellStatus;
	
	oldDay = day;
	day = newDay;
	
	if(oldCellType != cellType || oldCellStatus != cellStatus || oldDay != day)
		[self setNeedsDisplay];
}

- (CalendarCellType)cellType
{
	return cellType;
}

- (CalendarCellStatus)cellStatus
{
	return cellStatus;
}

- (uint)day
{
	return day;
}


#pragma mark -
#pragma mark memory management

- (void)dealloc {
	
	CGColorRelease(bgColor);
	CGColorRelease(bgColorExtra);
	CGColorRelease(bgColorSelected);
	
	CGColorRelease(fgColor);
	CGColorRelease(fgColorExtra);
	CGColorRelease(fgColorSelected);
	
    [super dealloc];
}


@end
