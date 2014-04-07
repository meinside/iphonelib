//
//  SQLiteResultRow.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 2014.04.07.
//

#import "SQLiteResultRow.h"

#import "Logging.h"


@implementation SQLiteResultRow

#pragma mark -
#pragma mark initializers

- (id)init
{
	if((self = [super init]))
	{
		columnsArray = [[NSMutableArray alloc] init];
		columnsDictionary = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+ (id)row
{
	return [[[SQLiteResultRow alloc] init] autorelease];
}

#pragma mark -
#pragma mark add column

- (id)addColumn:(SQLiteQueryParameter*)column
{
	[columnsArray addObject:column];
	[columnsDictionary setObject:column forKey:[column name]];
	
	return self;
}

#pragma mark -
#pragma mark getter functions

- (int)columnCount
{
	return (int)[columnsArray count];
}

- (NSArray*)columnNames
{
	return [columnsDictionary allKeys];
}

- (SQLiteQueryParameter*)columnAtIndex:(int)index
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return nil;
	}

	return [columnsArray objectAtIndex:index];
}

- (SQLiteQueryParameter*)columnWithName:(NSString*)name
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
		DebugLog(@"no such column with name: %@", name);
	
	return column;
}

- (int)intValueAtColumnWithIndex:(int)index ifNull:(int)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return -1;
	}
	
	return [[columnsArray objectAtIndex:index] intValueIfNull:defaultValue];
}

- (double)floatValueAtColumnWithIndex:(int)index ifNull:(double)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return -1.0f;
	}
	
	return [[columnsArray objectAtIndex:index] floatValueIfNull:defaultValue];
}

- (NSData*)blobValueAtColumnWithIndex:(int)index ifNull:(NSData*)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return nil;
	}
	
	return [[columnsArray objectAtIndex:index] blobValueIfNull:defaultValue];
}

- (NSString*)textValueAtColumnWithIndex:(int)index ifNull:(NSString*)defaultValue
{
	if(index >= [columnsArray count])
	{
		DebugLog(@"no such column with index: %d", index);
		return nil;
	}

	return [[columnsArray objectAtIndex:index] textValueIfNull:defaultValue];
}

- (int)intValueAtColumnWithName:(NSString*)name ifNull:(int)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return -1;
	}
	
	return [column intValueIfNull:defaultValue];
}

- (double)floatValueAtColumnWithName:(NSString*)name ifNull:(double)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return -1.0f;
	}
	
	return [column floatValueIfNull:defaultValue];
}

- (NSData*)blobValueAtColumnWithName:(NSString*)name ifNull:(NSData*)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return nil;
	}
	
	return [column blobValueIfNull:defaultValue];
}

- (NSString*)textValueAtColumnWithName:(NSString*)name ifNull:(NSString*)defaultValue
{
	SQLiteQueryParameter* column = [columnsDictionary objectForKey:name];
	if(!column)
	{
		DebugLog(@"no such column with name: %@", name);
		return nil;
	}
	
	return [column textValueIfNull:defaultValue];
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[columnsArray release];
	[columnsDictionary release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"columnsArray = %@", columnsArray];
	[description appendString:@", "];
	[description appendFormat:@"columnsDictionary = %@", columnsDictionary];
	
	[description appendString:@"}"];	
	return description;
}

@end
