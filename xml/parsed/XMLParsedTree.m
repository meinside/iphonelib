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
//  XMLParsedTree.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 10.08.17.
//

#import "XMLParsedTree.h"

#import "Logging.h"


@implementation XMLParsedTree

@synthesize root;

#pragma mark -
#pragma mark initializer

- (id)initWithRootElement:(XMLParsedElement*)rootElement
{
	if(self = [super init])
	{
		self.root = rootElement;
	}
	return self;
}

#pragma mark -
#pragma mark tree-traverse functions

- (id)traverse:(NSArray*)names nameIndex:(NSInteger)index element:(XMLParsedElement*)element
{
	NSString* name = [names objectAtIndex:index];
	if(![[element name] isEqualToString:name])
		return nil;
	
	if([names count] == index + 1)
	{
		return element;	//found target
	}
	else
	{
		id child;
		if(child = [element childWithName:[names objectAtIndex:(index + 1)]])
			return [self traverse:names nameIndex:(index + 1) element:child];
		else
			return nil;
	}
	
	return nil;
}

#pragma mark -
#pragma mark getter functions

- (XMLParsedElement*)elementAtPath:(NSString*)path
{
	return [self traverse:[path componentsSeparatedByString:@"/"] nameIndex:0 element:root];
}

- (XMLParsedTree*)parsedTreeAtPath:(NSString*)path
{
	XMLParsedElement* element = [self elementAtPath:path];
	if(element)
		return [[[XMLParsedTree alloc] initWithRootElement:element] autorelease];
	else
		return nil;
}

- (NSArray*)childrenAtPath:(NSString*)path
{
	return [[self elementAtPath:path] children];
}

- (NSDictionary*)namesAndValuesOfChildrenAtPath:(NSString*)path
{
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	for(XMLParsedElement* child in [[self elementAtPath:path] children])
	{
		[dic setValue:([child value] ? [child value] : [NSString stringWithString:@""]) forKey:[child name]];
	}
	return [dic autorelease];
}

- (NSDictionary*)attributesAtPath:(NSString*)path
{
	return [[self elementAtPath:path] attributes];
}

- (NSString*)attributeValueOfName:(NSString*)attributeName atPath:(NSString*)path
{
	return [[[self elementAtPath:path] attributes] valueForKey:attributeName];
}

- (NSString*)valueAtPath:(NSString*)path
{
	return [[self elementAtPath:path] value];
}

- (NSString*)stringValue
{
	return [self stringValueWithEncoding:NSUTF8StringEncoding];
}

- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding
{
	NSString* enc;
	switch(encoding)
	{
		case NSUTF8StringEncoding:
			enc = [NSString stringWithString:@"UTF-8"];
			break;
		default:
			enc = [NSString stringWithString:@"UTF-8"];
			break;
	}
	return [NSString stringWithFormat:@"<?xml version='1.0' encoding='%@'?>\n%@", enc, [root stringRepresentation]];
}

+ (XMLParsedTree*)XMLParsedTreeWithRootElement:(XMLParsedElement*)rootElement
{
	id parsedTree = [[XMLParsedTree alloc] initWithRootElement:rootElement];
	if(parsedTree)
	{
		return [parsedTree autorelease];
	}
	return nil;
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[root release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];
	
	[description appendFormat:@"root = %@", root];
	
	[description appendString:@"}"];

	//remove unnecessary escape characters
	[description replaceOccurrencesOfString:@"\\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [description length])];
	[description replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [description length])];
	
	return description;
}

@end
