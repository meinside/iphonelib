//
//  SQLiteQuery.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 11.04.28.
//

#import "SQLiteQuery.h"

#import "SQLiteQueryParameter.h"
#import "Logging.h"


@implementation SQLiteQuery

#pragma mark -
#pragma mark initializer

- (id)initWithQueryString:(NSString*)aQuery
{
	if((self = [super init]))
	{
		query = [aQuery copy];
		values = [[NSMutableArray alloc] init];
	}
	
	return self;
}

+ (SQLiteQuery*)queryWithQueryString:(NSString*)aQuery
{
	return [[[SQLiteQuery alloc] initWithQueryString:aQuery] autorelease];
}

#pragma mark -
#pragma mark add params

- (id)addIntegerParamWithValue:(int)value
{
	[values addObject:[SQLiteQueryParameter integerParameterWithName:nil number:value]];
	return self;
}

- (id)addFloatParamWithValue:(double)value
{
	[values addObject:[SQLiteQueryParameter floatParameterWithName:nil number:value]];
	return self;
}

- (id)addTextParamWithValue:(NSString*)value
{
	[values addObject:[SQLiteQueryParameter textParameterWithName:nil string:value]];
	return self;
}

- (id)addBlobParamWithValue:(NSData*)value
{
	[values addObject:[SQLiteQueryParameter blobParameterWithName:nil data:value]];
	return self;
}

- (id)addNullParam
{
	[values addObject:[SQLiteQueryParameter nullParameterWithName:nil]];
	return self;
}

#pragma mark -
#pragma mark getter functions

- (NSString*)queryString
{
	return query;
}

- (NSArray*)bindArguments
{
	return values;
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[query release];
	[values release];

	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"query = %@", query];
	[description appendString:@", "];
	[description appendFormat:@"values = %@", values];
	
	[description appendString:@"}"];	
	return description;
}

@end
