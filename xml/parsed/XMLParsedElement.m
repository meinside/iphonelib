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
//  XMLParsedElement.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 10.07.21.
//

#import "XMLParsedElement.h"

#import "Logging.h"


@implementation XMLParsedElement

@synthesize name;
@synthesize value;
@synthesize attributes;
@synthesize parent;
@synthesize children;

#pragma mark -
#pragma mark initializer

- (id) initWithName:(NSString*)aName value:(NSString*)nilIfNone
{
	if(self = [super init])
	{
		self.name = aName;
		self.value = nilIfNone;
		attributes = [[NSMutableDictionary alloc] init];
		parent = nil;
		children = [[NSMutableArray alloc] init];
		childrenNameIndex = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark attribute functions

- (void)addAttributeWithKey:(NSString*)aKey andValue:(NSString*)aValue
{
	[attributes setValue:aValue forKey:aKey];
}

#pragma mark -
#pragma mark child functions

- (void)addChild:(id)aChild
{
	[children addObject:aChild];
	if(![childrenNameIndex valueForKey:[aChild name]])
	{
		[childrenNameIndex setValue:aChild forKey:[aChild name]];
	}
}

- (BOOL)hasChild
{
	if([children count] <= 0)
		return NO;
	return YES;
}

- (id)childWithName:(NSString*)aName
{
	if([self hasChild])
	{
		return [childrenNameIndex valueForKey:aName];
	}
	return nil;
}

- (NSString*)valueOfChildWithName:(NSString*)aName
{
	XMLParsedElement* child = [self childWithName:aName];
	if(child)
	{
		return [child value];
	}
	return nil;
}

#pragma mark -
#pragma mark helper functions

- (NSString*)stringRepresentationWithTab:(NSInteger)tabSize
{
	//tab
	NSMutableString* strTab = [NSMutableString stringWithString:@""];
	for(int i=0;i<tabSize;i++)
	{
		[strTab appendString:@"\t"];
	}
	
	//attributes
	NSMutableString* strAttributes = [NSMutableString stringWithString:@""];
	for(NSString* key in [attributes allKeys])
	{
		[strAttributes appendString:@" "];
		[strAttributes appendFormat:@"%@=\"%@\"", key, [attributes valueForKey:key]];
	}
	
	//value
	NSMutableString* str = [NSMutableString stringWithFormat:@"%@<%@%@>", strTab, self.name, strAttributes];
	if(value && ![value isEqualToString:@""])
	{
		[str appendString:value];
		[str appendFormat:@"</%@>", self.name];
	}
	else if(children)
	{
		[str appendString:@"\n"];
		for(XMLParsedElement* child in children)
		{
			[str appendString:[child stringRepresentationWithTab:tabSize + 1]];
		}
		[str appendFormat:@"%@</%@>", strTab, self.name];
	}
	[str appendString:@"\n"];

	return str;
}

- (NSString*)stringRepresentation
{
	return [self stringRepresentationWithTab:0];
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[name release];

	if(value)
		[value release];
	if(parent)
		[parent release];
	
	[attributes release];
	[children release];
	[childrenNameIndex release];
	
	[super dealloc];
}

@end
