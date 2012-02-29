//
//  SimpleCalendarCellView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 10.07.21.
//

#pragma once
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

#define CELL_FG_COLOR_R 0.0f
#define CELL_FG_COLOR_G 0.0f
#define CELL_FG_COLOR_B 0.0f
#define CELL_EXTRA_FG_COLOR_R 0.5f
#define CELL_EXTRA_FG_COLOR_G 0.5f
#define CELL_EXTRA_FG_COLOR_B 0.5f
#define CELL_SELECTED_FG_COLOR_R 0.0f
#define CELL_SELECTED_FG_COLOR_G 0.0f
#define CELL_SELECTED_FG_COLOR_B 0.0f

#define CELL_BORDER_LINE_COLOR_R 0.0f
#define CELL_BORDER_LINE_COLOR_G 0.0f
#define CELL_BORDER_LINE_COLOR_B 0.0f

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
