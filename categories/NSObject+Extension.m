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
//  NSObject+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 10. 19.
//
//  last update: 11.10.19.
//

#import "NSObject+Extension.h"

#import <objc/runtime.h>

#import "Logging.h"


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

@end
