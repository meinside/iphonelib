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
//  HTTPParamList.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 16.
//
//  last update: 10.07.21.
//

#import "HTTPParamList.h"

#import "Logging.h"


@implementation HTTPParamList

@synthesize params;
@synthesize includesFile;

#pragma mark -
#pragma mark initializers

- (id)init
{
	if(self = [super init])
	{
		params = [[NSMutableDictionary alloc] init];
		includesFile = NO;
	}
	return self;
}

+ (id)paramList
{
	id paramList = [[HTTPParamList alloc] init];
	if(paramList)
		return [paramList autorelease];
	else
		return nil;
}

#pragma mark -
#pragma mark parameter adders

- (void)addParam:(HTTPParam*)newParam
{
	[params setValue:newParam forKey:[newParam paramName]];
}

- (void)addPlainParamWithName:(NSString*)name value:(NSString*)value
{
	[params setValue:[HTTPParam plainParamWithName:name value:value] forKey:name];
}

- (void)addFileParamWithName:(NSString*)name fillename:(NSString*)filename content:(NSData*)content contentType:(NSString*)contentType
{
	includesFile = YES;
	[params setValue:[HTTPParam fileParamWithName:name fillename:filename content:content contentType:contentType] forKey:name];
}

#pragma mark -
#pragma mark getter functions

- (id)paramWithName:(NSString*)name;
{
	return [params valueForKey:name];
}

- (NSArray*)paramsArray
{
	NSMutableArray* array = [[NSMutableArray alloc] init];
	for(NSString* key in [params allKeys])
	{
		[array addObject:[params valueForKey:key]];
	}
	return [array autorelease];
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[params release];
	
	[super dealloc];
}

@end
