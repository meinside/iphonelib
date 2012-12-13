//
//  SimpleCalendarCellView.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 2012.12.13.
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
		if(cellStatus == CalendarCellStatusSelected)
		{
			[QuartzHelper setFillColorOfContext:context withColor:fgColorSelected];
		}
		else if(cellType != CalendarCellTypeCurrentMonth)
		{
			[QuartzHelper setFillColorOfContext:context withColor:fgColorExtra];
		}
		else
		{
			[QuartzHelper setFillColorOfContext:context withColor:fgColor];
		}
		[[NSString stringWithFormat:@"%02d", day] drawInRect:rect
													withFont:[UIFont fontWithName:DAY_FONT size:(rect.size.width / DIVIDER_FOR_DAY_FONT_SIZE)] 
											   lineBreakMode:NSLineBreakByWordWrapping 
												   alignment:NSTextAlignmentRight];
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
