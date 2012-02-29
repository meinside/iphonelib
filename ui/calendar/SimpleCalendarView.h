//
//  SimpleCalendarView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 10.10.12.
//

#pragma once
#import <UIKit/UIKit.h>

#import "SimpleCalendarCellView.h"


#define CALENDAR_HEADER_HEIGHT 32
#define CALENDAR_WEEKDAY_HEADER_HEIGHT 10

#define CALENDAR_COLUMN_COUNT 7
#define CALENDAR_ROW_COUNT 6

#define BUTTON_WIDTH 20
#define BUTTON_HEIGHT 20
#define BUTTON_SPACE 40

#define MONTH_LABEL_WIDTH 80
#define MONTH_LABEL_HEIGHT 20

#define MONTH_LABEL_FONT @"Helvetica-Bold"	//font for month label
#define MONTH_LABEL_FONT_SIZE 18	//font size for month label

//color for month label
#define MONTH_LABEL_FG_COLOR_R 1.0f
#define MONTH_LABEL_FG_COLOR_G 1.0f
#define MONTH_LABEL_FG_COLOR_B 1.0f

#define WEEKDAY_LABEL_FONT @"Helvetica"	//font for weekday label
#define WEEKDAY_LABEL_FONT_SIZE 9	//font size for weekday label

//color for calendar background
#define CALENDAR_BG_COLOR_R 0.25f
#define CALENDAR_BG_COLOR_G 0.25f
#define CALENDAR_BG_COLOR_B 0.25f

//labels for weekdays
#define WEEKDAY_LABEL_SUNDAY	@"SUN"
#define WEEKDAY_LABEL_MONDAY	@"MON"
#define WEEKDAY_LABEL_TUESDAY	@"TUE"
#define WEEKDAY_LABEL_WEDNESDAY	@"WED"
#define WEEKDAY_LABEL_THURSDAY	@"THU"
#define WEEKDAY_LABEL_FRIDAY	@"FRI"
#define WEEKDAY_LABEL_SATURDAY	@"SAT"

//colors for weekday labels
#define WEEKDAY_LABEL_SUNDAY_COLOR_R 1.0f
#define WEEKDAY_LABEL_SUNDAY_COLOR_G 0.0f
#define WEEKDAY_LABEL_SUNDAY_COLOR_B 0.0f
#define WEEKDAY_LABEL_SATURDAY_COLOR_R 0.0f
#define WEEKDAY_LABEL_SATURDAY_COLOR_G 0.0f
#define WEEKDAY_LABEL_SATURDAY_COLOR_B 1.0f
#define WEEKDAY_LABEL_OTHERDAY_COLOR_R 1.0f
#define WEEKDAY_LABEL_OTHERDAY_COLOR_G 1.0f
#define WEEKDAY_LABEL_OTHERDAY_COLOR_B 1.0f

@protocol SimpleCalendarViewDelegate;

@interface SimpleCalendarView : UIView {

	NSMutableArray* cells;
	SimpleCalendarCellView* currentSelectedCell;
	SimpleCalendarCellView* lastSelectedCell;
	
	UIButton* previousMonthButton;
	UIButton* nextMonthButton;
	
	UILabel* monthLabel;
	
	uint selectedYear, selectedMonth, selectedDay;
	
	id<SimpleCalendarViewDelegate> delegate;
}

+ (NSDateComponents*)dateCompWithDayAdded:(int)dayAdded toYear:(uint)year month:(uint)month day:(uint)day;
+ (NSDateComponents*)dateCompWithMonthAdded:(int)monthAdded toYear:(uint)year month:(uint)month day:(uint)day;
+ (NSDateComponents*)dateCompWithYearAdded:(int)yearAdded toYear:(uint)year month:(uint)month day:(uint)day;

- (void)gotoPreviousDay:(id)sender;
- (void)gotoNextDay:(id)sender;
- (void)gotoPreviousMonth:(id)sender;
- (void)gotoNextMonth:(id)sender;
- (void)gotoPreviousYear:(id)sender;
- (void)gotoNextYear:(id)sender;

- (void)refresh;	//refresh calendar for today
- (void)refreshWithYear:(int)year month:(int)month day:(int)day;

- (void)cellPressed:(id)sender;

@property (nonatomic, readonly) uint selectedYear;
@property (nonatomic, readonly) uint selectedMonth;
@property (nonatomic, readonly) uint selectedDay;
@property (assign) id<SimpleCalendarViewDelegate> delegate;

@end

@protocol SimpleCalendarViewDelegate<NSObject>

- (void)calendar:(SimpleCalendarView*)calendar cellWasSelected:(SimpleCalendarCellView*)cell;

@end

