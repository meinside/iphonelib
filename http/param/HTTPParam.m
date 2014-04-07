//
//  HTTPParam.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 13.
//
//  last update: 2014.04.07.
//

#import "HTTPParam.h"

#import "Logging.h"


@implementation HTTPParam

@synthesize paramType;
@synthesize paramValue;
@synthesize paramName;
@synthesize additionalValues;

#pragma mark -
#pragma mark initializers

- (id)initWithName:(NSString*)name value:(NSData*)data
{
	if((self = [super init]))
	{
		self.paramName = name;
		self.paramValue = data;
		additionalValues = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (HTTPParam*)plainParamWithName:(NSString*)name value:(NSString*)someValue
{
	HTTPParam* param = [[HTTPParam alloc] initWithName:name value:[someValue dataUsingEncoding:NSUTF8StringEncoding]];
	param.paramType = HTTPUtilParamTypePlain;
	return [param autorelease];
}

+ (HTTPParam*)fileParamWithName:(NSString*)name fillename:(NSString*)filename content:(NSData*)content contentType:(NSString*)contentType
{
	HTTPParam* param = [[HTTPParam alloc] initWithName:name value:content];
	param.paramType = HTTPUtilParamTypeFile;
	[param.additionalValues setValue:filename forKey:PARAM_FILENAME];
	[param.additionalValues setValue:contentType forKey:PARAM_CONTENTTYPE];
	return [param autorelease];
}

#pragma mark -
#pragma mark getter functions

- (BOOL)isFile
{
	return (paramType == HTTPUtilParamTypeFile);
}

- (BOOL)isPlainText
{
	return (paramType == HTTPUtilParamTypePlain);
}

- (NSString*)fileName
{
	return [additionalValues valueForKey:PARAM_FILENAME];
}

- (NSString*)contentType
{
	return [additionalValues valueForKey:PARAM_CONTENTTYPE];
}

- (NSString*)paramStringValue
{
	NSString* stringValue = [[NSString alloc] initWithData:paramValue encoding:NSUTF8StringEncoding];
	return [stringValue autorelease];
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[paramValue release];
	[additionalValues release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark overriding NSObject's description function

- (NSString *)description
{
	NSMutableString* description = [NSMutableString string];
	[description appendFormat:@"%@ {", [self class]];

	[description appendFormat:@"paramType = %ld", (long)paramType];
	[description appendString:@", "];
	[description appendFormat:@"paramName = %@", paramName];
	[description appendString:@", "];
	[description appendFormat:@"paramValue = %@", paramValue];
	[description appendString:@", "];
	[description appendFormat:@"additionalValues = %@", additionalValues];
	if([self isFile])
	{
		[description appendString:@", "];
		[description appendFormat:@"fileName = %@", [self fileName]];
		[description appendString:@", "];
		[description appendFormat:@"contentType = %@", [self contentType]];
	}
	else
	{
		[description appendString:@", "];
		[description appendFormat:@"paramStringValue = %@", [self paramStringValue]];
	}

	[description appendString:@"}"];	
	return description;
}


@end
