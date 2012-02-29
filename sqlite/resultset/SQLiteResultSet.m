//
//  SQLiteResultSet.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 11.04.28.
//

#import "SQLiteResultSet.h"

#import "Logging.h"


@implementation SQLiteResultSet

#pragma mark -
#pragma mark initializer

- (id)init
{
	if((self = [super init]))
	{
		rows = [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark -
#pragma mark add result row

- (void)addResultRow:(SQLiteResultRow*)row
{
	[rows addObject:row];
}

#pragma mark -
#pragma mark getter functions

- (int)rowCount
{
	return [rows count];
}

- (SQLiteResultRow*)rowAtIndex:(int)index
{
	if(index >= [rows count])
	{
		DebugLog(@"no such row with index: %d", index);
		return nil;
	}
	
	return [rows objectAtIndex:index];
}

- (SQLiteQueryParameter*)valueAtRow:(int)rowIndex column:(int)columnIndex
{
	return [[self rowAtIndex:rowIndex] columnAtIndex:columnIndex];
}

- (SQLiteQueryParameter*)valueAtRow:(int)rowIndex columnName:(NSString*)columnName
{
	return [[self rowAtIndex:rowIndex] columnWithName:columnName];
}

#pragma mark -
#pragma mark for fast enumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [rows countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[rows release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"rows = %@", rows];
	
	[description appendString:@"}"];
	
	//remove unnecessary escape characters
	[description replaceOccurrencesOfString:@"\\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [description length])];
	[description replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [description length])];
	
	return description;
}

@end
