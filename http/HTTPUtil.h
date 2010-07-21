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
//  HTTPUtil.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 06.
//
//  last update: 10.07.21.
//

#pragma once
#import <Foundation/Foundation.h>

#include "HTTPParamList.h"

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

@end
