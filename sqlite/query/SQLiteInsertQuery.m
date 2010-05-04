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
//  SQLiteInsertQuery.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.05.04.
//

#import "SQLiteInsertQuery.h"


@implementation SQLiteInsertQuery

#pragma mark -
#pragma mark initializer

- (id)initWithTableName:(NSString*)aTableName
{
	if(self = [super init])
	{
		tableName = [aTableName copy];
		array = [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark add params

- (id)addQueryParameter:(SQLiteQueryParameter*)param
{
	[array addObject:param];
	return self;
}

- (id)addIntegerParamWithName:(NSString*)name value:(int)value
{
	[array addObject:[SQLiteQueryParameter integerParameterWithName:name number:value]];
	return self;
}

- (id)addFloatParamWithName:(NSString*)name value:(double)value
{
	[array addObject:[SQLiteQueryParameter floatParameterWithName:name number:value]];
	return self;
}

- (id)addTextParamWithName:(NSString*)name value:(NSString*)value
{
	[array addObject:[SQLiteQueryParameter textParameterWithName:name string:value]];
	return self;
}

- (id)addBlobParamWithName:(NSString*)name value:(NSData*)value
{
	[array addObject:[SQLiteQueryParameter blobParameterWithName:name data:value]];
	return self;
}

- (id)addNullParamWithName:(NSString*)name
{
	[array addObject:[SQLiteQueryParameter nullParameterWithName:name]];
	return self;
}

#pragma mark -
#pragma mark getter functions

- (NSString*)tableName
{
	return tableName;
}

- (id)parameters
{
	return array;
}

- (id)paramAtIndex:(int)index
{
	return [array objectAtIndex:index];
}

- (int)columnCount
{
	return [array count];
}

- (NSString*)queryString
{
	NSMutableString* queryString = [NSMutableString string];
	int columnCount = [array count];
	
	[queryString appendString:@"INSERT INTO "];
	[queryString appendString:tableName];
	[queryString appendString:@"("];

	for(int i=0; i<columnCount; i++)
	{
		if(i != 0)
			[queryString appendString:@","];
		[queryString appendString:[[array objectAtIndex:i] name]];
	}
	[queryString appendString:@") VALUES ("];
	for(int i=0; i<columnCount; i++)
	{
		if(i != 0)
			[queryString appendString:@","];
		[queryString appendString:@"?"];
	}
	[queryString appendString:@")"];
	
	return queryString;
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[tableName release];
	[array release];
	
	[super dealloc];
}

@end
