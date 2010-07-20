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
//  SimpleCalendarCellView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 10.07.04.
//

#import <UIKit/UIKit.h>


#define DAY_FONT @"Helvetica-Bold"	//font for day number labels
#define DIVIDER_FOR_DAY_FONT_SIZE 3.5	//divider for font size of day number labels

#define CELL_BG_COLOR_R 1.0f
#define CELL_BG_COLOR_G 1.0f
#define CELL_BG_COLOR_B 1.0f
#define CELL_EXTRA_BG_COLOR_R 0.9f
#define CELL_EXTRA_BG_COLOR_G 0.9f
#define CELL_EXTRA_BG_COLOR_B 0.9f
#define CELL_SELECTED_BG_COLOR_R 0.3f
#define CELL_SELECTED_BG_COLOR_G 0.5f
#define CELL_SELECTED_BG_COLOR_B 0.7f

#define CELL_FG_COLOR_R 0.2f
#define CELL_FG_COLOR_G 0.2f
#define CELL_FG_COLOR_B 0.2f
#define CELL_EXTRA_FG_COLOR_R 0.5f
#define CELL_EXTRA_FG_COLOR_G 0.5f
#define CELL_EXTRA_FG_COLOR_B 0.5f
#define CELL_SELECTED_FG_COLOR_R 0.0f
#define CELL_SELECTED_FG_COLOR_G 0.0f
#define CELL_SELECTED_FG_COLOR_B 0.0f

#define CELL_BORDER_LINE_COLOR_R 0.8f
#define CELL_BORDER_LINE_COLOR_G 0.8f
#define CELL_BORDER_LINE_COLOR_B 0.8f

typedef enum _CalendarCellType
{
	CalendarCellTypeNone,
	CalendarCellTypePreviousMonth,
	CalendarCellTypeCurrentMonth,
	CalendarCellTypeNextMonth,
} CalendarCellType;

typedef enum _CalendarCellStatus
{
	CalendarCellStatusNone,
	CalendarCellStatusSelected,
} CalendarCellStatus;

@interface SimpleCalendarCellView : UIControl {
	
	CalendarCellType cellType, oldCellType;
	CalendarCellStatus cellStatus, oldCellStatus;

	CGColorRef bgColor, bgColorExtra, bgColorSelected;
	CGColorRef fgColor, fgColorExtra, fgColorSelected;

	uint day, oldDay;
}

- (void)setCellType:(CalendarCellType)newCellType;
- (void)setCellStatus:(CalendarCellStatus)newCellStatus;
- (void)setDay:(uint)newDay;

- (CalendarCellType)cellType;
- (CalendarCellStatus)cellStatus;
- (uint)day;

- (void)setCellType:(CalendarCellType)newCellType 
		 cellStatus:(CalendarCellStatus)newCellStatus 
				day:(uint)newDay;

@end
