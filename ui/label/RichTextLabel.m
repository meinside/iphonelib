//
//  RichTextLabel.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 09. 08.
//
//  last update: 11.01.21.
//


#import "RichTextLabel.h"

#import "Logging.h"


@implementation RichTextLabel

@synthesize html;
@synthesize bgColor;
@synthesize margin;
@synthesize padding;
@synthesize fontSize;
@synthesize letterSpacing;
@synthesize lineHeight;
@synthesize fontFamily;
@synthesize align;

- (void)initialize
{
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	self.dataDetectorTypes = UIDataDetectorTypeNone;
	self.userInteractionEnabled = NO;
	
	//default values
	self.bgColor = RL_DEFAULT_BG_COLOR;
	self.margin = RL_DEFAULT_MARGIN;
	self.padding = RL_DEFAULT_PADDING;
	self.fontSize = RL_DEFAULT_FONT_SIZE;
	self.letterSpacing = RL_DEFAULT_LETTER_SPACING;
	self.lineHeight = RL_DEFAULT_LINE_HEIGHT;
	self.fontFamily = RL_DEFAULT_FONT_FAMILY;
	self.align = RL_DEFAULT_TEXT_ALIGN;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self initialize];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	
	[bgColor release];
	[fontFamily release];

	[html release];

    [super dealloc];
}

#pragma mark -
#pragma mark setting html

- (void)changeText:(NSString *)htmlString
{
	if(htmlString != html)
	{
		[html release];
		html = [htmlString retain];
		
		if(html)
		{
			/*
			 <!-- example -->
			 <html>
				<header><title></title></header>
				<body style='background-color:transparent; margin:0px; padding:0px; font-size:20px; letter-spacing:2px; line-height:2px font-family: Helvetica'>
				<div style='text-align:right; width:120px; height:21px'><font color='red'>t</font>est</div>
			 </body>
			 </html>
			 */
			NSMutableString* str = [NSMutableString string];
			[str appendString:@"<html>"];
			[str appendString:@"<header><title>rich text label</title></header>"];
			[str appendFormat:@"<body style=\"background-color:%@; margin:%dpx; padding:%dpx; font-size:%dpx; letter-spacing:%dpx; line-height:%dpx font-family: '%@';\">", bgColor, margin, padding, fontSize, letterSpacing, lineHeight, fontFamily];
			
			NSString* alignString;
			switch(align)
			{
				case TextAlignLeft:
					alignString = @"left";
					break;
				case TextAlignCenter:
					alignString = @"center";
					break;
				case TextAlignRight:
					alignString = @"right";
					break;
			}
			[str appendFormat:@"<div style=\"text-align:%@; width:%dpx; height:%dpx;\">%@</div>", alignString, (int)self.frame.size.width, (int)self.frame.size.height, html == nil ? @"" : html];
			[str appendString:@"</body>"];
			[str appendString:@"</html>"];
			
//			DebugLog(@"changing label html to: %@", str);
			
//			[self loadHTMLString:str baseURL:[[NSBundle mainBundle] bundleURL]];	//for under iOS 4.0
			[self loadHTMLString:str baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
		}
		else
		{
			[self loadHTMLString:@"" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
		}
	}
}


#pragma mark -
#pragma mark NSObject overrides

- (NSString*)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];
	[description appendString:html];
	[description appendString:@"}"];	
	return description;
}


@end
