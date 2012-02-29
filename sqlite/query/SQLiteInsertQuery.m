//
//  SQLiteInsertQuery.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 11.04.28.
//

#import "SQLiteInsertQuery.h"

#import "Logging.h"


@implementation SQLiteInsertQuery

#pragma mark -
#pragma mark initializer

- (id)initWithTableName:(NSString*)aTableName
{
	if((self = [super init]))
	{
		tableName = [aTableName copy];
		array = [[NSMutableArray alloc] init];
	}
	
	return self;
}

+ (SQLiteInsertQuery*)queryWithTableName:(NSString*)aTableName
{
	return [[[SQLiteInsertQuery alloc] initWithTableName:aTableName] autorelease];
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


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];
	
	[description appendFormat:@"tableName = %@", tableName];
	[description appendString:@", "];
	[description appendFormat:@"array = %@", array];
	
	[description appendString:@"}"];	
	return description;
}

@end
