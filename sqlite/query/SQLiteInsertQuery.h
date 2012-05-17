//
//  SQLiteInsertQuery.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 12.05.17.
//

#pragma once
#import <Foundation/Foundation.h>

#import "SQLiteQueryParameter.h"


@interface SQLiteInsertQuery : NSObject {

	NSString* tableName;
	NSMutableArray* array;
	BOOL replace;
}

- (id)initWithTableName:(NSString*)aTableName;
- (id)initWithTableName:(NSString*)aTableName 
				replace:(BOOL)replaceOrNot;

+ (SQLiteInsertQuery*)queryWithTableName:(NSString*)aTableName;
+ (SQLiteInsertQuery*)queryWithTableName:(NSString*)aTableName 
								 replace:(BOOL)replaceOrNot;

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
