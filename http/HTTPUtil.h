//
//  HTTPUtil.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 06.
//
//  last update: 12.12.04.
//

#pragma once
#import <Foundation/Foundation.h>

#include "HTTPParamList.h"

#define kHTTP_ASYNC_RESULT_HTTPUTIL_OBJ @"obj"
#define kHTTP_ASYNC_RESULT_CODE @"code"
#define kHTTP_ASYNC_RESULT_CONTENTTYPE @"mime"
#define kHTTP_ASYNC_RESULT_CHARENCODING @"encoding"
#define kHTTP_ASYNC_RESULT_DATA @"data"
#define kHTTP_ASYNC_RESULT_ERRORSTR @"error"
#define kHTTP_ASYNC_RESULT_HEADERFIELDS @"headers"


@interface HTTPUtil : NSObject {

	//variables for async jobs
	NSURLConnection* asyncConnection;
	id asyncResultHandler;
	SEL asyncResultSelector;
	NSURLResponse* asyncResponse;
	NSMutableData* asyncResultData;
}

- (void)cancelCurrentConnection;

/*
 * Synchronous HTTP functions
 *
 * - set 'timeout' less or equal to 0.0 to ignore request timeout value
 */
+ (NSData*)dataResultFromGetRequestWithURL:(NSURL*)url 
								parameters:(NSDictionary*)params 
					additionalHeaderFields:(NSDictionary*)headerFields 
						   timeoutInterval:(NSTimeInterval)timeout
								  response:(NSURLResponse**)response 
									 error:(NSError**)error;
+ (NSData*)dataResultFromPostRequestWithURL:(NSURL*)url 
								 parameters:(HTTPParamList*)params 
					 additionalHeaderFields:(NSDictionary*)headerFields 
							timeoutInterval:(NSTimeInterval)timeout
								   response:(NSURLResponse**)response 
									  error:(NSError**)error;

/*
 * Asynchronous HTTP functions
 * 
 * With these async functions,
 * delegates receive NSDictionary objects through selectors.
 * 
 * The NSDictionary objects will contain key-values returned from HTTP URL connection.
 * You can retrieve specific value from them with kHTTP_ASYNC_RESULT_*.
 *
 * - set 'timeout' less or equal to 0.0 to ignore request timeout value
 */
- (BOOL)sendAsyncGetRequestWithURL:(NSURL*)url 
						parameters:(NSDictionary*)params 
			additionalHeaderFields:(NSDictionary*)headerFields 
				   timeoutInterval:(NSTimeInterval)timeout
								to:(id)delegate 
						  selector:(SEL)selector;
- (BOOL)sendAsyncPostRequestWithURL:(NSURL*)url 
						 parameters:(HTTPParamList*)params 
			 additionalHeaderFields:(NSDictionary*)headerFields 
					timeoutInterval:(NSTimeInterval)timeout
								 to:(id)delegate 
						   selector:(SEL)selector;
- (BOOL)sendAsyncRequest:(NSURLRequest*)request
					  to:(id)delegate
				selector:(SEL)selector;

@end
