//
//  HTTPParamList.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 16.
//
//  last update: 10.09.29.
//

#pragma once
#import <Foundation/Foundation.h>

#include "HTTPParam.h"

@interface HTTPParamList : NSObject {
	NSMutableDictionary* params;
	BOOL includesFile;
}

+ (HTTPParamList*)paramList;

+ (HTTPParamList*)paramListFromDictionary:(NSDictionary*)dict;

- (void)addParam:(HTTPParam*)newParam;
- (void)addPlainParamWithName:(NSString*)name value:(NSString*)value;
- (void)addFileParamWithName:(NSString*)name fillename:(NSString*)filename content:(NSData*)content contentType:(NSString*)contentType;
- (id)paramWithName:(NSString*)name;

- (NSArray*)paramsArray;

//sort parameters by their name, append together, and then generate MD5 digest from it
- (NSString*)hash;

@property (retain, nonatomic) NSMutableDictionary* params;
@property (assign, nonatomic) BOOL includesFile;

@end
