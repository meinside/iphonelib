/*
 Copyright (c) 2010, Sungjin Han <meinside@gmail.com>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of meinside nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */
//
//  SqliteWrapper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 10. 10.
//
//  last update: 10.04.28.
//

#import "SqliteWrapper.h"


@implementation SqliteWrapper

@synthesize lastErrorMessage;

#pragma mark -
#pragma mark initializer

- (id)initWithFilepath:(NSString*)filePath
{
	sqlite3* db;
	int error;
	if((error = sqlite3_open([filePath UTF8String], &db)) != SQLITE_OK)
	{
		DebugLog(@"sqlite3_open failed(%d) with %@", error, [filePath UTF8String]);

		sqlite3_close(db);
		return nil;
	}

	if(self = [super init])
	{
		database = db;
		self.lastErrorMessage = SQLITE_STRING_NO_ERROR;
	}
	
	return self;
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

- (bool)executeQuery:(SqliteQuery*)query
{
	NSString* queryString = [query queryString];
	sqlite3_stmt *stmt = NULL;
	bool success = NO;
	
	if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		NSArray* bindArgs = [query bindArguments];
		if(bindArgs && [bindArgs count] > 0)
		{
			SqliteQueryParameter* param;
			NSObject* value;
			for(int i=0; i<[bindArgs count]; i++)
			{
				param = [bindArgs objectAtIndex:i];
				value = [param value];
				if(value != nil)
				{
					switch((int)[param type])
					{
						case SqliteInteger:
							sqlite3_bind_int(stmt, i+1, [(NSNumber*)value intValue]);
							break;
						case SqliteFloat:
							sqlite3_bind_double(stmt, i+1, [(NSNumber*)value doubleValue]);
							break;
						case SqliteBlob:
							sqlite3_bind_blob(stmt, i+1, [(NSData*)value bytes], [(NSData*)value length], SQLITE_STATIC);
							break;
						case SqliteNull:
							sqlite3_bind_null(stmt, i+1);
							break;
						case SqliteText:
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
												  
- (bool)insertWithQuery:(SqliteInsertQuery*)query
{
	NSString* queryString = [query queryString];
	int columnCount = [query columnCount];	
	sqlite3_stmt *stmt = NULL;
	bool success = NO;

	if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		SqliteQueryParameter* param;
		NSObject* value;
		for(int i=0; i<columnCount; i++)
		{
			param = [query paramAtIndex:i];
			value = [param value];
			if(value != nil)
			{
				switch((int)[param type])
				{
					case SqliteInteger:
						sqlite3_bind_int(stmt, i+1, [(NSNumber*)value intValue]);
						break;
					case SqliteFloat:
						sqlite3_bind_double(stmt, i+1, [(NSNumber*)value doubleValue]);
						break;
					case SqliteBlob:
						sqlite3_bind_blob(stmt, i+1, [(NSData*)value bytes], [(NSData*)value length], SQLITE_STATIC);
						break;
					case SqliteNull:
						sqlite3_bind_null(stmt, i+1);
						break;
					case SqliteText:
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

- (SqliteResultSet*)selectWithQuery:(SqliteQuery*)query
{
	NSString* queryString = [query queryString];
	sqlite3_stmt *stmt = NULL;
	bool success = NO;
	
	SqliteResultSet* rows = nil;
	
	if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		NSArray* bindArgs = [query bindArguments];
		if(bindArgs && [bindArgs count] > 0)
		{
			SqliteQueryParameter* param;
			NSObject* value;
			for(int i=0; i<[bindArgs count]; i++)
			{
				param = [bindArgs objectAtIndex:i];
				value = [param value];
				if(value != nil)
				{
					switch((int)[param type])
					{
						case SqliteInteger:
							sqlite3_bind_int(stmt, i+1, [(NSNumber*)value intValue]);
							break;
						case SqliteFloat:
							sqlite3_bind_double(stmt, i+1, [(NSNumber*)value doubleValue]);
							break;
						case SqliteBlob:
							sqlite3_bind_blob(stmt, i+1, [(NSData*)value bytes], [(NSData*)value length], SQLITE_STATIC);
							break;
						case SqliteNull:
							sqlite3_bind_null(stmt, i+1);
							break;
						case SqliteText:
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
		
		rows = [[SqliteResultSet alloc] init];
		SqliteResultRow* row;
		
		int stepResult;
		int columnCount;

		NSString* columnName;

		int numBytes;
		void* bytes;

		while ((stepResult = sqlite3_step(stmt)) == SQLITE_ROW)
		{
			row = [SqliteResultRow row];
			columnCount = sqlite3_column_count(stmt);
			for(int i=0; i<columnCount; i++)
			{
				columnName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
				switch(sqlite3_column_type(stmt, i))
				{
					case SqliteInteger:
						[row addColumn:[SqliteQueryParameter integerParameterWithName:columnName 
																			   number:sqlite3_column_int(stmt, i)]];
						break;
					case SqliteFloat:
						[row addColumn:[SqliteQueryParameter floatParameterWithName:columnName 
																			 number:sqlite3_column_double(stmt, i)]];
						break;
					case SqliteBlob:
						numBytes = sqlite3_column_bytes(stmt, i);
						bytes = (void*)sqlite3_column_blob(stmt, i);
						[row addColumn:[SqliteQueryParameter blobParameterWithName:columnName 
																			  data:[NSData dataWithBytes:bytes length:numBytes]]];
						break;
					case SqliteText:
						[row addColumn:[SqliteQueryParameter textParameterWithName:columnName 
																			string:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)]]];
						break;
					case SqliteNull:
						[row addColumn:[SqliteQueryParameter nullParameterWithName:columnName]];
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

- (bool)updateWithQuery:(SqliteQuery*)query
{
	return [self executeQuery:query];
}

#pragma mark -
#pragma mark delete

- (bool)deleteWithQuery:(SqliteQuery*)query
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
