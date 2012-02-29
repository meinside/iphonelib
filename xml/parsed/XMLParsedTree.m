//
//  XMLParsedTree.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 11.04.28.
//

#import "XMLParsedTree.h"

#import "Logging.h"


@implementation XMLParsedTree

@synthesize root;

#pragma mark -
#pragma mark initializer

- (id)initWithRootElement:(XMLParsedElement*)rootElement
{
	if((self = [super init]))
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
		if((child = [element childWithName:[names objectAtIndex:(index + 1)]]))
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
