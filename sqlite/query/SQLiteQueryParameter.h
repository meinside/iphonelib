//
//  SQLiteQueryParameter.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.05.04.
//

#pragma once
#import <Foundation/Foundation.h>

#import <sqlite3.h>	//needs: libsqlite3.dylib

enum SQLiteQueryParameterType {
	SQLiteInteger = SQLITE_INTEGER,
	SQLiteFloat = SQLITE_FLOAT,
	SQLiteBlob = SQLITE_BLOB,
	SQLiteNull = SQLITE_NULL,
	SQLiteText = SQLITE_TEXT,
};

@interface SQLiteQueryParameter : NSObject {
	
	int type;
	NSString* name;
	NSObject* value;
}

- (id)initWithType:(int)aType name:(NSString*)aName value:(NSObject*)aValue;

+ (id)queryParameterWithType:(int)aType name:(NSString*)aName value:(NSObject*)aValue;

+ (id)integerParameterWithName:(NSString*)name number:(int)number;

+ (id)floatParameterWithName:(NSString*)name number:(double)number;

+ (id)blobParameterWithName:(NSString*)name data:(NSData*)data;

+ (id)nullParameterWithName:(NSString*)name;

+ (id)textParameterWithName:(NSString*)name string:(NSString*)string;

- (id)value;

- (int)intValue;
- (int)intValueIfNull:(int)defaultValue;

- (double)floatValue;
- (double)floatValueIfNull:(double)defaultValue;

- (NSData*)blobValue;
- (NSData*)blobValueIfNull:(NSData*)defaultValue;

- (NSString*)textValue;
- (NSString*)textValueIfNull:(NSString*)defaultValue;

- (NSString*)name;

- (int)type;

@end
