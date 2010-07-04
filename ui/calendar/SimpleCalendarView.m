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
//  SimpleCalendarView.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 10.07.04.
//

#import "SimpleCalendarView.h"

#import "Logging.h"
#import "QuartzHelper.h"


@implementation SimpleCalendarView

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		
		//set background color
		CGColorRef bgColor = [QuartzHelper createColorRefWithR:0.25f G:0.25f B:0.25f A:1.0f];
		[self setBackgroundColor:[UIColor colorWithCGColor:bgColor]];
		CGColorRelease(bgColor);

		CGFloat height = frame.size.height;
		CGFloat width = frame.size.width;
		CGFloat cellWidth = width / CALENDAR_COLUMN_COUNT;
		CGFloat cellHeight = (height - CALENDAR_HEADER_HEIGHT) / CALENDAR_ROW_COUNT;
		CGFloat leftMargin = (width - cellWidth * CALENDAR_COLUMN_COUNT) / 2;
		CGFloat topMargin = (height - CALENDAR_HEADER_HEIGHT - cellHeight * CALENDAR_ROW_COUNT) / 2;
		
		//add prev/next month button
		previousMonthButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[previousMonthButton setTitle:@"<" forState:UIControlStateNormal];
		previousMonthButton.frame = CGRectMake(leftMargin + BUTTON_SPACE, (topMargin + CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT);
		[previousMonthButton addTarget:self action:@selector(previousMonth:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:previousMonthButton];
		nextMonthButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[nextMonthButton setTitle:@">" forState:UIControlStateNormal];
		nextMonthButton.frame = CGRectMake(width - BUTTON_SPACE - BUTTON_WIDTH, (topMargin + CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT);
		[nextMonthButton addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:nextMonthButton];
		
		//add month label
		monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - MONTH_LABEL_WIDTH) / 2, (topMargin + CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT - MONTH_LABEL_HEIGHT) / 2, MONTH_LABEL_WIDTH, MONTH_LABEL_HEIGHT)];
		monthLabel.text = [NSString stringWithFormat:@"%04d / %02d", 1981, 6];
		monthLabel.textAlignment = UITextAlignmentCenter;
		monthLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
		monthLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:MONTH_LABEL_FONT_SIZE];
		monthLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
		[self addSubview:monthLabel];
		
		//add weekday header labels
		NSArray* weekDays = [NSArray arrayWithObjects:WEEKDAY_LABEL_SUNDAY, WEEKDAY_LABEL_MONDAY, WEEKDAY_LABEL_TUESDAY, WEEKDAY_LABEL_WEDNESDAY, WEEKDAY_LABEL_THURSDAY, WEEKDAY_LABEL_FRIDAY, WEEKDAY_LABEL_SATURDAY, nil];
		for(int i=0; i<CALENDAR_COLUMN_COUNT; i++)
		{
			UILabel* weekday = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin + (i * cellWidth), 
																		 CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT + topMargin, 
																		 cellWidth, 
																		 CALENDAR_WEEKDAY_HEADER_HEIGHT)];
			weekday.text = [weekDays objectAtIndex:i];
			weekday.textAlignment = UITextAlignmentRight;
			weekday.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
			switch(i)
			{
				case 0:	//Sunday
					weekday.textColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
					break;
				case 6:	//Saturday
					weekday.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
					break;
				default:
					weekday.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
					break;
			}
			weekday.font = [UIFont fontWithName:@"Helvetica" size:WEEKDAY_LABEL_FONT_SIZE];
			[self addSubview:weekday];
			[weekday release];
		}

		//add calendar cell views
		cells = [[NSMutableArray alloc] init];
		for(int i=0; i<CALENDAR_ROW_COUNT; i++)
		{
			for(int j=0; j<CALENDAR_COLUMN_COUNT; j++)
			{
				SimpleCalendarCellView* cell = [[SimpleCalendarCellView alloc] initWithFrame:CGRectMake(leftMargin + (j * cellWidth), 
																										CALENDAR_HEADER_HEIGHT + topMargin + (i * cellHeight), 
																										cellWidth, 
																										cellHeight)];

				//add target
				[cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];

				[cells addObject:cell];
				[self addSubview:cell];
				[cell release];
			}
		}
		
		//set delegate
		delegate = nil;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark -
#pragma mark calendar-manipulating functions

- (void)previousMonth:(id)sender
{
	//DebugLog(@"previous month!");

	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];

	//calculate previous month
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:selectedYear];
	[dateComp setMonth:selectedMonth];
	[dateComp setDay:selectedDay];
	NSDate* oldDay = [calendar dateFromComponents:dateComp];
	[dateComp release];
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:-1];
	NSDate* previousMonth = [calendar dateByAddingComponents:dateComp 
													  toDate:oldDay 
													 options:0];
	[dateComp release];

	//refresh
	dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
						   fromDate:previousMonth];
	[self refreshWithYear:[dateComp year] 
					month:[dateComp month] 
					  day:[dateComp day]];
}

- (void)nextMonth:(id)sender
{
	//DebugLog(@"next month!");
	
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	
	//calculate next month
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:selectedYear];
	[dateComp setMonth:selectedMonth];
	[dateComp setDay:selectedDay];
	NSDate* oldDay = [calendar dateFromComponents:dateComp];
	[dateComp release];
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:+1];
	NSDate* nextMonth = [calendar dateByAddingComponents:dateComp 
												  toDate:oldDay 
												 options:0];
	[dateComp release];
	
	//refresh
	dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
						   fromDate:nextMonth];
	[self refreshWithYear:[dateComp year] 
					month:[dateComp month] 
					  day:[dateComp day]];
}

- (void)refresh;	//refresh calendar for today
{
	int year, month, day;
	NSDateComponents* dateComp = [[NSCalendar autoupdatingCurrentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	year = [dateComp year];
	month = [dateComp month];
	day = [dateComp day];
	
	[self refreshWithYear:year month:month day:day];
}

- (void)refreshWithYear:(int)year month:(int)month day:(int)day
{
	selectedYear = year;
	selectedMonth = month;
	selectedDay = day;
	
	//update year-month label
	monthLabel.text = [NSString stringWithFormat:@"%04d / %02d", selectedYear, selectedMonth];

	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	
	//DebugLog(@"selected year = %d, month = %d, day = %d", selectedYear, selectedMonth, selectedDay);

	//calculate first day of given month
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:selectedYear];
	[dateComp setMonth:selectedMonth];
	[dateComp setDay:1];
	NSDate* day1 = [calendar dateFromComponents:dateComp];
	int firstWeekday = [[calendar components:NSWeekdayCalendarUnit fromDate:day1] weekday];
	[dateComp release];

	//DebugLog(@"first week day of this month = %d, %@", firstWeekday, day1);

	//calculate number of days in previous month
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:-1];
	NSDate* previousMonth = [calendar dateByAddingComponents:dateComp 
													  toDate:day1 
													 options:0];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit 
								   inUnit:NSMonthCalendarUnit 
								  forDate:previousMonth];
	int numDaysOfPrevMonth = range.length;
	range = [calendar rangeOfUnit:NSDayCalendarUnit 
						   inUnit:NSMonthCalendarUnit 
						  forDate:day1];
	int numDaysOfCurrentMonth = range.length;
	[dateComp release];

	//DebugLog(@"number of days in current/previous month = %d/%d", numDaysOfCurrentMonth, numDaysOfPrevMonth);
	
	//setup calendar cells
	int cellIndex = 0;
	int dayNumberBase;
	for(SimpleCalendarCellView* cell in cells)
	{
		dayNumberBase = (cellIndex + 1) - (firstWeekday - 1);

		if(cellIndex + 1 < firstWeekday)	//days of previous month
		{
			[cell setCellType:CalendarCellTypePreviousMonth 
				   cellStatus:CalendarCellStatusNone 
						  day:dayNumberBase + numDaysOfPrevMonth];
		}
		else if(cellIndex + 1 > firstWeekday - 1 + numDaysOfCurrentMonth)	//days of next month
		{
			[cell setCellType:CalendarCellTypeNextMonth 
				   cellStatus:CalendarCellStatusNone 
						  day:dayNumberBase - numDaysOfCurrentMonth];
		}
		else	//days of current month
		{
			if(dayNumberBase == selectedDay)
			{
				[cell setCellType:CalendarCellTypeCurrentMonth 
					   cellStatus:CalendarCellStatusSelected 
							  day:dayNumberBase];
				currentSelectedCell = cell;
				
				//send a notification to the delegate
				[delegate calendar:self 
				   cellWasSelected:cell];
			}
			else
			{
				[cell setCellType:CalendarCellTypeCurrentMonth 
					   cellStatus:CalendarCellStatusNone 
							  day:dayNumberBase];
			}
		}
		
		cellIndex ++;
	}
}


#pragma mark -
#pragma mark functions for event processing

- (NSDateComponents*)dateCompWithMonthAdded:(uint)monthAdded toYear:(uint)year month:(uint)month day:(uint)day
{
	//get date from last selected date
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:year];
	[dateComp setMonth:month];
	[dateComp setDay:day];
	
	//get date from newly selected date
	NSDate* selectedDate = [calendar dateFromComponents:dateComp];
	[dateComp release];
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:monthAdded];
	NSDate* addedMonth = [calendar dateByAddingComponents:dateComp 
												   toDate:selectedDate 
												  options:0];
	[dateComp release];
	
	//move to previous month & selected day
	return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
					   fromDate:addedMonth];
}

- (void)cellPressed:(id)sender
{
	//DebugLog(@"cell pressed: %@", sender);

	if([sender cellType] == CalendarCellTypePreviousMonth)
	{
		NSDateComponents* dateComp = [self dateCompWithMonthAdded:-1 
														   toYear:selectedYear 
															month:selectedMonth 
															  day:[sender day]];
		
		//move to previous month & selected day
		[self refreshWithYear:[dateComp year] 
						month:[dateComp month] 
						  day:[sender day]];
	}
	else if([sender cellType] == CalendarCellTypeNextMonth)
	{
		NSDateComponents* dateComp = [self dateCompWithMonthAdded:+1 
														   toYear:selectedYear 
															month:selectedMonth 
															  day:[sender day]];
		
		//move to next month & selected day
		[self refreshWithYear:[dateComp year] 
						month:[dateComp month] 
						  day:[sender day]];
	}
	else	//if([pressed cellType] == CalendarCellTypeCurrentMonth)
	{
		lastSelectedCell = currentSelectedCell;
		currentSelectedCell = sender;
		selectedDay = [sender day];

		[lastSelectedCell setCellStatus:CalendarCellStatusNone];
		[currentSelectedCell setCellStatus:CalendarCellStatusSelected];
		
		//send a notification to the delegate
		[delegate calendar:self 
		   cellWasSelected:sender];
	}
}


#pragma mark -
#pragma mark delegate functions

- (void)setDelegate:(id<SimpleCalendarViewDelegate>)newDelegate
{
	if(delegate)
	{
		[delegate release];
		delegate = nil;
	}
	delegate = [newDelegate retain];
}


#pragma mark -
#pragma mark memory management

- (void)dealloc {

	[cells release];
	[previousMonthButton release];
	[nextMonthButton release];
	[monthLabel release];
	
	[delegate release];
	
    [super dealloc];
}


@end
