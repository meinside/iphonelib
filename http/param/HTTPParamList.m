//
//  HTTPParamList.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 16.
//
//  last update: 11.04.28.
//

#import "HTTPParamList.h"

#import "Logging.h"

#import "NSString+Extension.h"


@implementation HTTPParamList

@synthesize params;
@synthesize includesFile;

#pragma mark -
#pragma mark initializers

- (id)init
{
	if((self = [super init]))
	{
		params = [[NSMutableDictionary alloc] init];
		includesFile = NO;
	}
	return self;
}

+ (HTTPParamList*)paramList
{
	return [[[HTTPParamList alloc] init] autorelease];
}

+ (HTTPParamList*)paramListFromDictionary:(NSDictionary*)dict
{
	HTTPParamList* result = [self paramList];
	for(NSString* key in [dict allKeys])
	{
		[result addPlainParamWithName:key value:[dict valueForKey:key]];
	}
	return result;
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

- (NSString*)hash
{
	NSMutableString* string = [NSMutableString string];

	for(NSString* key in [[params allKeys] sortedArrayUsingSelector:@selector(compare:)])
	{
		if([string length] > 0)
			[string appendString:@"&"];
		[string appendString:key];
		[string appendString:@"="];
		[string appendString:[[params valueForKey:key] paramStringValue]];
	}
	
	//DebugLog(@"hash of '%@' = '%@'", string, [string md5Digest]);
	
	return [string md5Digest];
}

- (void)dealloc
{
	[params release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];
	
	[description appendFormat:@"includesFile = %d", includesFile];
	[description appendString:@", "];
	[description appendFormat:@"params = %@", params];
	[description appendString:@", "];
	[description appendFormat:@"hash = %@", [self hash]];
	
	[description appendString:@"}"];	
	return description;
}

@end
