//
//  XMLParsedElement.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 11.04.28.
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

- (id)initWithName:(NSString*)aName value:(NSString*)nilIfNone
{
	if((self = [super init]))
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

- (void)addChild:(XMLParsedElement*)aChild
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

- (XMLParsedElement*)childWithName:(NSString*)aName
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


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"name = %@", name];
	[description appendString:@", "];
	[description appendFormat:@"value = %@", value];
	[description appendString:@", "];
	[description appendFormat:@"attributes = %@", attributes];
	[description appendString:@", "];
	[description appendFormat:@"children = %@", children];
	[description appendString:@", "];
	[description appendFormat:@"childrenNameIndex = %@", childrenNameIndex];
	
	[description appendString:@"}"];	
	return description;
}

@end
