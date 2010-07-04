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
//  SimpleCalendarView.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 10.07.04.
//

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

#define MONTH_LABEL_FONT_SIZE 18	//font size for month label

#define WEEKDAY_LABEL_FONT_SIZE 9	//font size for weekday label

//labels for weekdays
#define WEEKDAY_LABEL_SUNDAY	@"SUN"
#define WEEKDAY_LABEL_MONDAY	@"MON"
#define WEEKDAY_LABEL_TUESDAY	@"TUE"
#define WEEKDAY_LABEL_WEDNESDAY	@"WED"
#define WEEKDAY_LABEL_THURSDAY	@"THU"
#define WEEKDAY_LABEL_FRIDAY	@"FRI"
#define WEEKDAY_LABEL_SATURDAY	@"SAT"

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

- (void)previousMonth:(id)sender;
- (void)nextMonth:(id)sender;

- (void)refresh;	//refresh calendar for today
- (void)refreshWithYear:(int)year month:(int)month day:(int)day;

- (void)cellPressed:(id)sender;

- (void)setDelegate:(id<SimpleCalendarViewDelegate>)newDelegate;

@end

@protocol SimpleCalendarViewDelegate<NSObject>

- (void)calendar:(SimpleCalendarView*)calendar cellWasSelected:(SimpleCalendarCellView*)cell;

@end

