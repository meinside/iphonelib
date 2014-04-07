//
//  SQLiteResultSet.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 20.
//
//  last update: 2014.04.07.
//

#pragma once
#import <Foundation/Foundation.h>

#import "SQLiteResultRow.h"
#import "SQLiteQueryParameter.h"


@interface SQLiteResultSet : NSObject <NSFastEnumeration> {

	NSMutableArray* rows;
}

- (id)init;

- (void)addResultRow:(SQLiteResultRow*)row;

- (NSUInteger)rowCount;

- (SQLiteResultRow*)rowAtIndex:(int)index;

- (SQLiteQueryParameter*)valueAtRow:(int)rowIndex column:(int)columnIndex;

- (SQLiteQueryParameter*)valueAtRow:(int)rowIndex columnName:(NSString*)columnName;

@end
