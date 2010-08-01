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
//  XMLParser.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 10.08.01.
//

#import "XMLParser.h"

#import "Logging.h"


@implementation XMLParser

@synthesize rootElement;
@synthesize parsedTree;

#pragma mark -
#pragma mark initializers

- (id)initWithURL:(NSURL*)url
{
	if(self = [super init])
	{
		parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		[parser setDelegate:self];
		parsed = NO;
		
		currentElementValue = nil;
		elementStack = [[NSMutableArray alloc] init];
		parsedTree = nil;
		
		error = nil;
		
		verbose = NO;
	}
	
	return self;
}

- (id)initWithURLString:(NSString *)path
{
	if(self = [super init])
	{
		parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:path]];
		[parser setDelegate:self];
		parsed = NO;

		currentElementValue = nil;
		elementStack = [[NSMutableArray alloc] init];
		parsedTree = nil;
		
		error = nil;
		
		verbose = NO;
	}
	
	return self;
}

- (id)initWithData:(NSData *)data
{
	if(self = [super init])
	{
		parser = [[NSXMLParser alloc] initWithData:data];
		[parser setDelegate:self];
		parsed = NO;

		currentElementValue = nil;
		elementStack = [[NSMutableArray alloc] init];
		parsedTree = nil;
		
		error = nil;
		
		verbose = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark stack functions

- (void)pushElement:(XMLParsedElement*)element
{
	[elementStack addObject:element];
}

- (XMLParsedElement*)popElement
{
	XMLParsedElement* popped = [[elementStack objectAtIndex:[elementStack count] - 1] retain];
	[elementStack removeLastObject];
	return [popped autorelease];
}

- (XMLParsedElement*)peekElement
{
	return [elementStack objectAtIndex:[elementStack count] - 1];
}

#pragma mark -
#pragma mark parse functions

- (BOOL)parse
{
	if(!parser)
		return NO;

	return [parser parse];
}

- (BOOL)parsed
{
	return parsed;
}

+ (XMLParsedTree*)XMLParsedTreeFromURL:(NSURL*)url
{
	XMLParser* parser = [[XMLParser alloc] initWithURL:url];
	if([parser parse])
	{
		XMLParsedTree* tree = [[parser parsedTree] retain];
		[parser release];
		return [tree autorelease];
	}
	[parser release];
	return nil;
}

+ (XMLParsedTree*)XMLParsedTreeFromURLString:(NSString*)path
{
	XMLParser* parser = [[XMLParser alloc] initWithURLString:path];
	if([parser parse])
	{
		XMLParsedTree* tree = [[parser parsedTree] retain];
		[parser release];
		return [tree autorelease];
	}
	[parser release];
	return nil;
}

+ (XMLParsedTree*)XMLParsedTreeFromData:(NSData*)data
{
	XMLParser* parser = [[XMLParser alloc] initWithData:data];
	if([parser parse])
	{
		XMLParsedTree* tree = [[parser parsedTree] retain];
		[parser release];
		return [tree autorelease];
	}
	[parser release];
	return nil;
}

#pragma mark -
#pragma mark etc.

- (void)setVerbose:(BOOL)verboseOrNot
{
	verbose = verboseOrNot;
}

- (void)dealloc
{
	if(parser)
	{
		[parser setDelegate:nil];
		[parser release];
	}
	if(error)
		[error release];
	if(elementStack)
		[elementStack release];
	if(rootElement)
		[rootElement release];
	if(parsedTree)
		[parsedTree release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark XMLParserDelegate functions

#ifndef __IPHONE_4_0

@end

@implementation XMLParser (XMLParserDelegate)

#endif

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	XMLParsedElement* newElement = [[XMLParsedElement alloc] initWithName:elementName value:nil];
	[newElement.attributes setDictionary:attributeDict];
	[self pushElement:newElement];
	[newElement release];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(!currentElementValue)
	{
		currentElementValue = [[NSMutableString alloc] initWithString:@""];
	}
	[currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	if(!currentElementValue)
	{
		currentElementValue = [[NSMutableString alloc] initWithString:@""];
	}
	/*
	 **** CDATA block is 'UTF-8 encoded' ****
	 (from the NSXMLParser class reference document)
	 Through this method the parser object passes the contents of the block to its delegate in an NSData object. 
	 The CDATA block is character data that is ignored by the parser. 
	 The encoding of the character data is UTF-8. To convert the data object to a string object, use the NSString method initWithData:encoding:.
	 */
	NSString* cdataString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	[currentElementValue appendString:cdataString];
	[cdataString release];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	XMLParsedElement* currentElement = [self popElement];
	currentElement.value = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if([elementStack count] > 0)
	{
		XMLParsedElement* parentElement = [self peekElement];
		[parentElement addChild:currentElement];
	}
	else
	{
		self.rootElement = currentElement;
	}
	
	if(verbose)
		DebugLog(@"%@, %@, %@: %@", elementName, namespaceURI, qName, currentElement.value);
	
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	XMLParsedTree* newTree = [[XMLParsedTree alloc] initWithRootElement:rootElement];
	self.parsedTree = newTree;
	[newTree release];

	parsed = YES;
}

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
	//ignore
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	//ignore
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
	//ignore
	return nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	error = [parseError retain];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	error = [validationError retain];
}

@end

