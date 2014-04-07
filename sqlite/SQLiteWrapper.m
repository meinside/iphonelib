//
//  SQLiteWrapper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 10. 10.
//
//  last update: 2014.04.07.
//

#import "SQLiteWrapper.h"

#import "FileUtil.h"
#import "SQLiteQueryParameter.h"
#import "SQLiteResultRow.h"
#import "Logging.h"


@implementation SQLiteWrapper

@synthesize lastErrorMessage;

#pragma mark -
#pragma mark initializer

- (id)initWithFilepath:(NSString*)filePath
{
	sqlite3* db;
	int error;
	if((error = sqlite3_open([filePath UTF8String], &db)) != SQLITE_OK)
	{
		DebugLog(@"sqlite3_open failed(%d) with %s", error, [filePath UTF8String]);

		sqlite3_close(db);
		return nil;
	}

	if((self = [super init]))
	{
		database = db;
		self.lastErrorMessage = SQLITE_STRING_NO_ERROR;
	}
	
	return self;
}

- (id)initWithResourceFilename:(NSString*)filename
{
	return [self initWithFilepath:[FileUtil pathOfFile:filename 
										  withPathType:PathTypeResource]];
}

- (id)initWithDocumentFilename:(NSString*)filename
{
	return [self initWithFilepath:[FileUtil pathOfFile:filename 
										  withPathType:PathTypeDocument]];
}


#pragma mark -
#pragma mark attach database

- (bool)attachDatabase:(NSString*)filepath 
		asDatabaseName:(NSString*)databaseName
{
	return [self executeQueryString:[NSString stringWithFormat:@"attach database \"%@\" as %@", filepath, databaseName]];
}


#pragma mark -
#pragma mark execute query

- (bool)executeQueryString:(NSString*)query
{
    char* error = NULL;
    if (sqlite3_exec(database, [query  UTF8String], NULL, NULL, &error) != SQLITE_OK)
	{
		self.lastErrorMessage = [NSString stringWithCString:error 
												   encoding:NSUTF8StringEncoding];
		
		DebugLog(@"error: %@", self.lastErrorMessage);
		
		sqlite3_free(error);
		return NO;
    }

	if(error)
		sqlite3_free(error);

	self.lastErrorMessage = SQLITE_STRING_NO_ERROR;
	return YES;
}

- (bool)executeQuery:(SQLiteQuery*)query
{
	NSString* queryString = [query queryString];
	sqlite3_stmt *stmt = NULL;
	bool success = NO;
	
	if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		NSArray* bindArgs = [query bindArguments];
		if(bindArgs && [bindArgs count] > 0)
		{
			SQLiteQueryParameter* param;
			NSObject* value;
			for(int i=0; i<[bindArgs count]; i++)
			{
				param = [bindArgs objectAtIndex:i];
				value = [param value];
				if(value != nil)
				{
					switch((int)[param type])
					{
						case SQLiteInteger:
							sqlite3_bind_int(stmt, i+1, [(NSNumber*)value intValue]);
							break;
						case SQLiteFloat:
							sqlite3_bind_double(stmt, i+1, [(NSNumber*)value doubleValue]);
							break;
						case SQLiteBlob:
							sqlite3_bind_blob(stmt, i+1, [(NSData*)value bytes], (int)[(NSData*)value length], SQLITE_STATIC);
							break;
						case SQLiteNull:
							sqlite3_bind_null(stmt, i+1);
							break;
						case SQLiteText:
							sqlite3_bind_text(stmt, i+1, [(NSString*)[param value] UTF8String], -1, SQLITE_STATIC);
							break;
						default:
							break;
					}
				}
				else
					sqlite3_bind_null(stmt, i+1);
			}
		}
		
		if (sqlite3_step(stmt) == SQLITE_DONE)
			success = YES;
	}
	
	if(success)
		self.lastErrorMessage = SQLITE_STRING_NO_ERROR;
	else
	{
		self.lastErrorMessage = [NSString stringWithCString:sqlite3_errmsg(database) 
												   encoding:NSUTF8StringEncoding];

		DebugLog(@"error: %@", self.lastErrorMessage);
	}
	
	if(stmt)
		sqlite3_finalize(stmt);
	
	return success;
}

#pragma mark -
#pragma mark create/drop table

- (bool)createTableWithQueryString:(NSString*)query
{
	return [self executeQueryString:query];
}

- (bool)dropTableWithQueryString:(NSString*)query
{
	return [self executeQueryString:query];
}

#pragma mark -
#pragma mark insert
												  
- (bool)insertWithQuery:(SQLiteInsertQuery*)query
{
	NSString* queryString = [query queryString];
	int columnCount = (int)[query columnCount];
	sqlite3_stmt *stmt = NULL;
	bool success = NO;

	if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		SQLiteQueryParameter* param;
		NSObject* value;
		for(int i=0; i<columnCount; i++)
		{
			param = [query paramAtIndex:i];
			value = [param value];
			if(value != nil)
			{
				switch((int)[param type])
				{
					case SQLiteInteger:
						sqlite3_bind_int(stmt, i+1, [(NSNumber*)value intValue]);
						break;
					case SQLiteFloat:
						sqlite3_bind_double(stmt, i+1, [(NSNumber*)value doubleValue]);
						break;
					case SQLiteBlob:
						sqlite3_bind_blob(stmt, i+1, [(NSData*)value bytes], (int)[(NSData*)value length], SQLITE_STATIC);
						break;
					case SQLiteNull:
						sqlite3_bind_null(stmt, i+1);
						break;
					case SQLiteText:
						sqlite3_bind_text(stmt, i+1, [(NSString*)[param value] UTF8String], -1, SQLITE_STATIC);
						break;
					default:
						break;
				}
			}
			else
				sqlite3_bind_null(stmt, i+1);

		}

		if (sqlite3_step(stmt) == SQLITE_DONE)
			success = YES;
	}

	if(success)
		self.lastErrorMessage = SQLITE_STRING_NO_ERROR;
	else
	{
		self.lastErrorMessage = [NSString stringWithCString:sqlite3_errmsg(database) 
												   encoding:NSUTF8StringEncoding];
		
		DebugLog(@"error: %@", self.lastErrorMessage);
	}

	if(stmt)
		sqlite3_finalize(stmt);

	return success;
}

#pragma mark -
#pragma mark select

- (SQLiteResultSet*)selectWithQuery:(SQLiteQuery*)query
{
	NSString* queryString = [query queryString];
	sqlite3_stmt *stmt = NULL;
	bool success = NO;
	
	SQLiteResultSet* rows = nil;
	
	if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		NSArray* bindArgs = [query bindArguments];
		if(bindArgs && [bindArgs count] > 0)
		{
			SQLiteQueryParameter* param;
			NSObject* value;
			for(int i=0; i<[bindArgs count]; i++)
			{
				param = [bindArgs objectAtIndex:i];
				value = [param value];
				if(value != nil)
				{
					switch((int)[param type])
					{
						case SQLiteInteger:
							sqlite3_bind_int(stmt, i+1, [(NSNumber*)value intValue]);
							break;
						case SQLiteFloat:
							sqlite3_bind_double(stmt, i+1, [(NSNumber*)value doubleValue]);
							break;
						case SQLiteBlob:
							sqlite3_bind_blob(stmt, i+1, [(NSData*)value bytes], (int)[(NSData*)value length], SQLITE_STATIC);
							break;
						case SQLiteNull:
							sqlite3_bind_null(stmt, i+1);
							break;
						case SQLiteText:
							sqlite3_bind_text(stmt, i+1, [(NSString*)[param value] UTF8String], -1, SQLITE_STATIC);
							break;
						default:
							break;
					}
				}
				else
					sqlite3_bind_null(stmt, i+1);
			}
		}
		
		rows = [[SQLiteResultSet alloc] init];
		SQLiteResultRow* row;
		
		int stepResult;
		int columnCount;

		NSString* columnName;

		int numBytes;
		void* bytes;

		while ((stepResult = sqlite3_step(stmt)) == SQLITE_ROW)
		{
			row = [SQLiteResultRow row];
			columnCount = sqlite3_column_count(stmt);
			for(int i=0; i<columnCount; i++)
			{
				columnName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
				switch(sqlite3_column_type(stmt, i))
				{
					case SQLiteInteger:
						[row addColumn:[SQLiteQueryParameter integerParameterWithName:columnName 
																			   number:sqlite3_column_int(stmt, i)]];
						break;
					case SQLiteFloat:
						[row addColumn:[SQLiteQueryParameter floatParameterWithName:columnName 
																			 number:sqlite3_column_double(stmt, i)]];
						break;
					case SQLiteBlob:
						numBytes = sqlite3_column_bytes(stmt, i);
						bytes = (void*)sqlite3_column_blob(stmt, i);
						[row addColumn:[SQLiteQueryParameter blobParameterWithName:columnName 
																			  data:[NSData dataWithBytes:bytes length:numBytes]]];
						break;
					case SQLiteText:
						[row addColumn:[SQLiteQueryParameter textParameterWithName:columnName 
																			string:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)]]];
						break;
					case SQLiteNull:
						[row addColumn:[SQLiteQueryParameter nullParameterWithName:columnName]];
						break;
					default:
						break;
				}
			}
			[rows addResultRow:row];
		}
		
		if(stepResult == SQLITE_DONE)
			success = YES;
		else
			[rows release];
	}

	if(success)
		self.lastErrorMessage = SQLITE_STRING_NO_ERROR;
	else
	{
		self.lastErrorMessage = [NSString stringWithCString:sqlite3_errmsg(database) 
												   encoding:NSUTF8StringEncoding];
		
		DebugLog(@"error: %@", self.lastErrorMessage);
	}
	
	if(stmt)
		sqlite3_finalize(stmt);
	
	return success ? [rows autorelease] : nil;
}

#pragma mark -
#pragma mark update

- (bool)updateWithQuery:(SQLiteQuery*)query
{
	return [self executeQuery:query];
}

#pragma mark -
#pragma mark delete

- (bool)deleteWithQuery:(SQLiteQuery*)query
{
	return [self executeQuery:query];
}

#pragma mark -
#pragma mark get last change/insert row id

- (sqlite3_int64)lastInsertRowId
{
	return sqlite3_last_insert_rowid(database);
}

- (int)totalChangesSinceConnection
{
	return sqlite3_total_changes(database);
}

- (int)changesSinceLastOperation
{
	return sqlite3_changes(database);
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	sqlite3_close(database);
	[lastErrorMessage release];
	
	[super dealloc];
}

@end
