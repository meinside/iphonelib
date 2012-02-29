//
//  SQLiteWrapper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 10. 10.
//
//  last update: 11.05.02.
//

#pragma once
#import <Foundation/Foundation.h>

//needs: libsqlite3.dylib
#import <sqlite3.h>

#import "SQLiteInsertQuery.h"
#import "SQLiteQuery.h"
#import "SQLiteResultSet.h"


#define SQLITE_STRING_NO_ERROR @"no error"

@interface SQLiteWrapper : NSObject {
	
    sqlite3* database;
	
	NSString* lastErrorMessage;
}

- (id)initWithFilepath:(NSString*)filePath;

- (id)initWithResourceFilename:(NSString*)filename;

- (id)initWithDocumentFilename:(NSString*)filename;

- (bool)attachDatabase:(NSString*)filepath 
		asDatabaseName:(NSString*)databaseName;

- (bool)createTableWithQueryString:(NSString*)query;

- (bool)dropTableWithQueryString:(NSString*)query;

- (bool)executeQueryString:(NSString*)query;

- (bool)executeQuery:(SQLiteQuery*)query;

- (bool)insertWithQuery:(SQLiteInsertQuery*)query;

- (SQLiteResultSet*)selectWithQuery:(SQLiteQuery*)query;

- (bool)updateWithQuery:(SQLiteQuery*)query;

- (bool)deleteWithQuery:(SQLiteQuery*)query;

- (sqlite3_int64)lastInsertRowId;

- (int)changesSinceLastOperation;

- (int)totalChangesSinceConnection;

@property (copy, readwrite) NSString* lastErrorMessage;

@end
