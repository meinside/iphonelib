//
//  SQLiteResultRow.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 10.07.21.
//

#pragma once
#import <Foundation/Foundation.h>

#import "SQLiteQueryParameter.h"


@interface SQLiteResultRow : NSObject {

	NSMutableArray* columnsArray;
	NSMutableDictionary* columnsDictionary;
}

- (id)init;

+ (id)row;

- (id)addColumn:(SQLiteQueryParameter*)column;

- (int)columnCount;

- (NSArray*)columnNames;

- (SQLiteQueryParameter*)columnAtIndex:(int)index;

- (SQLiteQueryParameter*)columnWithName:(NSString*)name;

- (int)intValueAtColumnWithIndex:(int)index ifNull:(int)defaultValue;

- (double)floatValueAtColumnWithIndex:(int)index ifNull:(double)defaultValue;

- (NSData*)blobValueAtColumnWithIndex:(int)index ifNull:(NSData*)defaultValue;

- (NSString*)textValueAtColumnWithIndex:(int)index ifNull:(NSString*)defaultValue;

- (int)intValueAtColumnWithName:(NSString*)name ifNull:(int)defaultValue;

- (double)floatValueAtColumnWithName:(NSString*)name ifNull:(double)defaultValue;

- (NSData*)blobValueAtColumnWithName:(NSString*)name ifNull:(NSData*)defaultValue;

- (NSString*)textValueAtColumnWithName:(NSString*)name ifNull:(NSString*)defaultValue;

@end
