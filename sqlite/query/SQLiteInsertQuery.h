//
//  SQLiteInsertQuery.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.08.24.
//

#pragma once
#import <Foundation/Foundation.h>

#import "SQLiteQueryParameter.h"


@interface SQLiteInsertQuery : NSObject {

	NSString* tableName;
	NSMutableArray* array;
}

- (id)initWithTableName:(NSString*)aTableName;

+ (SQLiteInsertQuery*)queryWithTableName:(NSString*)aTableName;

- (id)addQueryParameter:(SQLiteQueryParameter*)param;

- (id)addIntegerParamWithName:(NSString*)name value:(int)value;

- (id)addFloatParamWithName:(NSString*)name value:(double)value;

- (id)addTextParamWithName:(NSString*)name value:(NSString*)value;

- (id)addBlobParamWithName:(NSString*)name value:(NSData*)value;

- (id)addNullParamWithName:(NSString*)name;

- (NSString*)tableName;

- (id)parameters;

- (id)paramAtIndex:(int)index;

- (int)columnCount;

- (NSString*)queryString;

@end
