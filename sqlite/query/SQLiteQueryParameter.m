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
//  SQLiteQueryParameter.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.08.17.
//

#import "SQLiteQueryParameter.h"

#import "Logging.h"


@implementation SQLiteQueryParameter

#pragma mark -
#pragma mark initializers

- (id)initWithType:(int)aType name:(NSString*)aName value:(NSObject*)aValue
{
	if(self = [super init])
	{
		type = aType;
		name = [aName copy];
		value = [aValue retain];
	}
	
	return self;
}

+ (id)queryParameterWithType:(int)aType name:(NSString*)aName value:(NSObject*)aValue
{
	return [[[SQLiteQueryParameter alloc] initWithType:aType name:aName value:aValue] autorelease];
}

+ (id)integerParameterWithName:(NSString*)name number:(int)number
{
	return [SQLiteQueryParameter queryParameterWithType:SQLiteInteger name:name value:[NSNumber numberWithInt:number]];
}

+ (id)floatParameterWithName:(NSString*)name number:(double)number
{
	return [SQLiteQueryParameter queryParameterWithType:SQLiteFloat name:name value:[NSNumber numberWithFloat:number]];
}

+ (id)blobParameterWithName:(NSString*)name data:(NSData*)data
{
	return [SQLiteQueryParameter queryParameterWithType:SQLiteBlob name:name value:data];
}

+ (id)nullParameterWithName:(NSString*)name
{
	return [SQLiteQueryParameter queryParameterWithType:SQLiteNull name:name value:nil];
}

+ (id)textParameterWithName:(NSString*)name string:(NSString*)string
{
	return [SQLiteQueryParameter queryParameterWithType:SQLiteText name:name value:string];
}

#pragma mark -
#pragma mark getter functions

- (id)value
{
	return value;
}

- (int)intValue
{
	return [(NSNumber*)value intValue];
}

- (int)intValueIfNull:(int)defaultValue
{
	if(value)
		return [(NSNumber*)value intValue];
	else
		return defaultValue;
}

- (double)floatValue
{
	return [(NSNumber*)value doubleValue];
}

- (double)floatValueIfNull:(double)defaultValue
{
	if(value)
		return [(NSNumber*)value doubleValue];
	else
		return defaultValue;
}

- (NSData*)blobValue
{
	return (NSData*)value;
}

- (NSData*)blobValueIfNull:(NSData*)defaultValue
{
	if(value)
		return (NSData*)value;
	else
		return defaultValue;
}

- (NSString*)textValue
{
	return (NSString*)value;
}

- (NSString*)textValueIfNull:(NSString*)defaultValue
{
	if(value)
		return (NSString*)value;
	else
		return defaultValue;
}

- (NSString*)name
{
	return name;
}

- (int)type
{
	return type;
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[name release];
	[value release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];
	
	[description appendFormat:@"type = %d", type];
	[description appendString:@", "];
	[description appendFormat:@"name = %@", name];
	[description appendString:@", "];
	[description appendFormat:@"value = %@", value];
	
	[description appendString:@"}"];	
	return description;
}

@end
