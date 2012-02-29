//
//  HTTPParam.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 13.
//
//  last update: 10.01.16.
//

#pragma once
#import <Foundation/Foundation.h>

#define PARAM_FILENAME @"filename"
#define PARAM_CONTENTTYPE @"contenttype"

enum HTTPUtilParamType {
	HTTPUtilParamTypePlain = 0,
	HTTPUtilParamTypeFile = 1,
};

@interface HTTPParam : NSObject {

	NSInteger paramType;
	NSString* paramName;
	NSData* paramValue;
	NSMutableDictionary* additionalValues;
}

- (id)initWithName:(NSString*)name value:(NSData*)data;

+ (HTTPParam*)plainParamWithName:(NSString*)name value:(NSString*)someValue;
+ (HTTPParam*)fileParamWithName:(NSString*)name fillename:(NSString*)filename content:(NSData*)content contentType:(NSString*)contentType;

- (BOOL)isFile;
- (BOOL)isPlainText;

- (NSString*)fileName;
- (NSString*)contentType;
- (NSString*)paramStringValue;

@property (assign, nonatomic) NSInteger paramType;
@property (copy, nonatomic) NSData* paramValue;
@property (copy, nonatomic) NSString* paramName;
@property (retain, nonatomic) NSMutableDictionary* additionalValues;

@end
