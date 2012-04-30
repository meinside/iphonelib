//
//  NSObject+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 10. 19.
//
//  last update: 12.04.30.
//

#import "NSObject+Extension.h"

#import <objc/runtime.h>


@implementation NSObject (NSObjectExtension)

#pragma mark - helper functions for logging

//referenced: http://stackoverflow.com/questions/2410081/return-all-properties-of-an-object-in-objective-c
- (NSDictionary*)propertiesDictionaryOfObject:(id)obj withClassType:(Class)cls
{
	unsigned int propCount;
	objc_property_t* properties = class_copyPropertyList(cls, &propCount);
	
	NSMutableDictionary* result = [NSMutableDictionary dictionary];
	NSString* propertyName;
	id propertyValue;
	
	for(size_t i=0; i<propCount; i++)
	{
		@try
		{
			propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
			propertyValue = [obj valueForKey:propertyName];
			
			//DebugLog(@"name: %@, value: %@", propertyName, propertyValue);
			
			[result setValue:(propertyValue ? propertyValue : @"nil")
					  forKey:propertyName];
		}
		@catch (NSException* exception)
		{	/* do nothing */	}
	}
	free(properties);
	
	//lookup super classes
	Class superCls = class_getSuperclass(cls);
	while(superCls && ![superCls isEqual:[NSObject class]])
	{
		[result addEntriesFromDictionary:[self propertiesDictionaryOfObject:obj 
															  withClassType:superCls]];
		
		superCls = class_getSuperclass(superCls);
	}
	
	return result;
}

- (NSDictionary*)propertiesDictionary
{
	return [self propertiesDictionaryOfObject:self 
								withClassType:[self class]];
}

- (NSArray*)methodsArrayOfObject:(id)obj withClassType:(Class)cls
{
	unsigned int propCount;
	Method* methods = class_copyMethodList(cls, &propCount);
	
	NSMutableArray* result = [NSMutableArray array];
	NSString* methodName;
	
	for(size_t i=0; i<propCount; i++)
	{
		@try
		{
			methodName = NSStringFromSelector(method_getName(methods[i]));
			[result addObject:methodName];
		}
		@catch (NSException* exception)
		{	/* do nothing */	}
	}
	free(methods);
	
	return result;
}

- (NSArray*)methodsArray
{
	return [self methodsArrayOfObject:self 
						withClassType:[self class]];
}

@end
