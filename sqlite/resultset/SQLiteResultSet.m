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
