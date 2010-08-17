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
//  SQLiteResultRow.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.08.17.
//

#import "SQLiteResultRow.h"

#import "Logging.h"


@implementation SQLiteResultRow

#pragma mark -
#pragma mark initializers

- (id)init
{
	if(self = [super init])
	{
		columnsArray = [[NSMutableArray alloc] init];
		columnsDictionary = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+ (id)row
{
	return [[[SQLiteResultRow alloc] init] autorelease];
}

#pragma mark -
#pragma mark add column

- (id)addColumn:(SQLiteQueryParameter*)column
{
	[columnsArray addObject:column];
	[columnsDictionary setObject:column forKey:[column name]];
	
	return self;
}

#pragma mark -
#pragma mark getter functions

- (int)columnCount
{
	return [columnsArray count];
}

- (NSArray*)columnNames
{
	return [columnsDictionary allKeys];
}

- (SQLiteQueryParameter*)columnAtIndex:(int)index
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return nil;
	}

	return [columnsArray objectAtIndex:index];
}

- (SQLiteQueryParameter*)columnWithName:(NSString*)name
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
		DebugLog(@"no such column with name: %@", name);
	
	return column;
}

- (int)intValueAtColumnWithIndex:(int)index ifNull:(int)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return -1;
	}
	
	return [[columnsArray objectAtIndex:index] intValueIfNull:defaultValue];
}

- (float)floatValueAtColumnWithIndex:(int)index ifNull:(float)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return -1.0f;
	}
	
	return [[columnsArray objectAtIndex:index] floatValueIfNull:defaultValue];
}

- (NSData*)blobValueAtColumnWithIndex:(int)index ifNull:(NSData*)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return nil;
	}
	
	return [[columnsArray objectAtIndex:index] blobValueIfNull:defaultValue];
}

- (NSString*)textValueAtColumnWithIndex:(int)index ifNull:(NSString*)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return nil;
	}

	return [[columnsArray objectAtIndex:index] textValueIfNull:defaultValue];
}

- (int)intValueAtColumnWithName:(NSString*)name ifNull:(int)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return -1;
	}
	
	return [column intValueIfNull:defaultValue];
}

- (float)floatValueAtColumnWithName:(NSString*)name ifNull:(float)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return -1.0f;
	}
	
	return [column floatValueIfNull:defaultValue];
}

- (NSData*)blobValueAtColumnWithName:(NSString*)name ifNull:(NSData*)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return nil;
	}
	
	return [column blobValueIfNull:defaultValue];
}

- (NSString*)textValueAtColumnWithName:(NSString*)name ifNull:(NSString*)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return nil;
	}
	
	return [column textValueIfNull:defaultValue];
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[columnsArray release];
	[columnsDictionary release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"columnsArray = %@", columnsArray];
	[description appendString:@", "];
	[description appendFormat:@"columnsDictionary = %@", columnsDictionary];
	
	[description appendString:@"}"];	
	return description;
}

@end
