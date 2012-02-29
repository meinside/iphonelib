//
//  SQLiteQuery.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.07.21.
//

#pragma once
#import <Foundation/Foundation.h>


@interface SQLiteQuery : NSObject {
	
	NSString* query;
	NSMutableArray* values;
}

+ (SQLiteQuery*)queryWithQueryString:(NSString*)aQuery;

- (id)initWithQueryString:(NSString*)aQuery;

- (id)addIntegerParamWithValue:(int)value;

- (id)addFloatParamWithValue:(double)value;

- (id)addTextParamWithValue:(NSString*)value;

- (id)addBlobParamWithValue:(NSData*)value;

- (id)addNullParam;

- (NSString*)queryString;

- (NSArray*)bindArguments;

@end
