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
//  HTTPUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 06.
//
//  last update: 10.07.21.
//

#import "HTTPUtil.h"

#include "NSString+Extension.h"
#include "Logging.h"


@implementation HTTPUtil

#pragma mark -
#pragma mark initializers

- (id)init
{
	if(self = [super init])
	{
		asyncConnection = nil;
		asyncResultHandler = nil;
		asyncResultSelector = nil;
		asyncResponse = nil;
		asyncResultData = nil;
	}
	return self;
}

- (void)cancelCurrentConnection
{
	//cancel connection
	[asyncConnection cancel];

	//and release other things

	[asyncConnection release];
	asyncConnection = nil;

	[asyncResultHandler release];
	asyncResultHandler = nil;

	asyncResultSelector = nil;

	[asyncResultData release];
	asyncResultData = nil;
}

#pragma mark -
#pragma mark helper functions

+ (NSMutableURLRequest*)getRequestFromURL:(NSURL*)url 
							   parameters:(NSDictionary*)params 
				   additionalHeaderFields:(NSDictionary*)headerFields 
						  timeoutInterval:(NSTimeInterval)timeoutInterval
{
	NSMutableString* urlWithQuery = [NSMutableString stringWithString:[url absoluteString]];
	if(params)
	{
		[urlWithQuery appendString:@"?"];
		for(NSString* key in [params allKeys])
		{
			if(![urlWithQuery hasSuffix:@"?"])
			{
				[urlWithQuery appendString:@"&"];
			}
			[urlWithQuery appendFormat:@"%@=%@", [key urlencodedValue], [[params valueForKey:key] urlencodedValue]];
		}
	}
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlWithQuery]];
	[request setHTTPMethod:@"GET"];
	
	if(headerFields)
	{
		for(NSString* key in [headerFields allKeys])
		{
			[request addValue:[headerFields valueForKey:key] forHTTPHeaderField:key];
		}
	}

	if(timeoutInterval > 0.0)
		[request setTimeoutInterval:timeoutInterval];

	return request;
}

+ (NSMutableURLRequest*)postRequestFromURL:(NSURL*)url
								parameters:(HTTPParamList*)params 
					additionalHeaderFields:(NSDictionary*)headerFields 
						   timeoutInterval:(NSTimeInterval)timeoutInterval
{
	NSString* boundary = [NSString stringWithFormat:@"____boundary_%u____", [[NSDate date] timeIntervalSince1970]];
	NSString* contentType = nil;
	if(params.includesFile)
	{
		contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	}
	else
	{
		contentType = [NSString stringWithString:@"application/x-www-form-urlencoded"];
	}
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	if(params)
	{
		NSMutableData* postBody = [NSMutableData data];
		
		if(params.includesFile)
		{
			for(HTTPParam* param in [params paramsArray])
			{
				[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];	//boundary
				
				if([param isPlainText])
				{
					[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", [param paramName]] dataUsingEncoding:NSUTF8StringEncoding]];
					[postBody appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
					[postBody appendData:[param paramValue]];
				}
				else	//if([param isFile])
				{
					[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [param paramName], [param fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
					[postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [param contentType]] dataUsingEncoding:NSUTF8StringEncoding]];
					[postBody appendData:[param paramValue]];
				}
				
				//
				[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];	//boundary		
			}

			[postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];	//end boundary
		}
		else
		{
			NSMutableString* tempParam = [NSMutableString stringWithString:@""];
			for(HTTPParam* param in [params paramsArray])
			{
				if([tempParam length] > 0)
				{
					[tempParam appendString:@"&"];
				}
				[tempParam appendFormat:@"%@=%@", [param.paramName urlencodedValue], [[param paramStringValue] urlencodedValue]];
			}
			[postBody appendData:[tempParam dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
		[request setHTTPBody:postBody];
	}
	
	if(headerFields)
	{
		for(NSString* key in [headerFields allKeys])
		{
			[request addValue:[headerFields valueForKey:key] forHTTPHeaderField:key];
		}
	}
	
	if(timeoutInterval > 0.0)
		[request setTimeoutInterval:timeoutInterval];
	
	return request;
}

#pragma mark -
#pragma mark functions for synchronous HTTP methods

+ (NSData*)dataResultFromGetRequestWithURL:(NSURL*)url 
								parameters:(NSDictionary*)params 
					additionalHeaderFields:(NSDictionary*)headerFields 
						   timeoutInterval:(NSTimeInterval)timeout
								  response:(NSURLResponse**)response 
									 error:(NSError**)error
{
	@try
	{
		return [NSURLConnection sendSynchronousRequest:[self getRequestFromURL:url 
																	parameters:params 
														additionalHeaderFields:headerFields 
															   timeoutInterval:timeout] 
									 returningResponse:response 
												 error:error];
	}
	@catch (NSException * e) 
	{
		DebugLog(@"exception while get request: %@", [e description]);
	}
	return NULL;
}

+ (NSData*)dataResultFromPostRequestWithURL:(NSURL*)url 
								 parameters:(HTTPParamList*)params 
					 additionalHeaderFields:(NSDictionary*)headerFields 
							timeoutInterval:(NSTimeInterval)timeout
								   response:(NSURLResponse**)response 
									  error:(NSError**)error
{
	@try
	{
		return [NSURLConnection sendSynchronousRequest:[self postRequestFromURL:url 
																	 parameters:params 
														 additionalHeaderFields:headerFields 
																timeoutInterval:timeout] 
									 returningResponse:response 
												 error:error];
	}
	@catch (NSException * e) 
	{
		DebugLog(@"exception while post request: %@", [e description]);
	}
	return NULL;
}

#pragma mark -
#pragma mark functions for asynchronous HTTP methods

- (BOOL)sendAsyncGetRequestWithURL:(NSURL*)url 
						parameters:(NSDictionary*)params 
			additionalHeaderFields:(NSDictionary*)headerFields 
				   timeoutInterval:(NSTimeInterval)timeout
								to:(id)delegate 
						  selector:(SEL)selector
{
	@try
	{
		@synchronized(self)
		{
			//cancel on-going connection
			[self cancelCurrentConnection];
			
			asyncResultHandler = [delegate retain];
			asyncResultSelector = selector;
			
			asyncConnection = [[NSURLConnection alloc] initWithRequest:[HTTPUtil getRequestFromURL:url 
																						parameters:params 
																			additionalHeaderFields:headerFields 
																				   timeoutInterval:timeout] 
															  delegate:self
													  startImmediately:YES];
			return YES;
		}
	}
	@catch (NSException * e) 
	{
		[asyncConnection release];
		asyncConnection = nil;

		[asyncResultHandler release];
		asyncResultHandler = nil;

		asyncResultSelector = nil;
		
		[asyncResultData release];
		asyncResultData = nil;
		
		DebugLog(@"exception while async get request: %@", [e description]);
	}
	return NO;
}

- (BOOL)sendAsyncPostRequestWithURL:(NSURL*)url 
						 parameters:(HTTPParamList*)params 
			 additionalHeaderFields:(NSDictionary*)headerFields 
					timeoutInterval:(NSTimeInterval)timeout
								 to:(id)delegate 
						   selector:(SEL)selector
{
	@try
	{
		@synchronized(self)
		{
			//cancel on-going connection
			[self cancelCurrentConnection];
			
			asyncResultHandler = [delegate retain];
			asyncResultSelector = selector;
			
			asyncConnection = [[NSURLConnection alloc] initWithRequest:[HTTPUtil postRequestFromURL:url 
																						 parameters:params 
																			 additionalHeaderFields:headerFields 
																					timeoutInterval:timeout]
															  delegate:self 
													  startImmediately:YES];
			return YES;
		}
	}
	@catch (NSException * e) 
	{
		[asyncConnection release];
		asyncConnection = nil;
		
		[asyncResultHandler release];
		asyncResultHandler = nil;
		
		asyncResultSelector = nil;
		
		[asyncResultData release];
		asyncResultData = nil;

		DebugLog(@"exception while async post request: %@", [e description]);
	}
	return NO;
}

#pragma mark -
#pragma mark NSURLConnection delegate functions

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response
{
	@synchronized(self)
	{
		asyncResponse = [response retain];
	}
}

- (void)connection:(NSURLConnection *)connection 
	didReceiveData:(NSData *)data
{
	@try
	{
		@synchronized(self)
		{
			if(asyncResultData == nil)
				asyncResultData = [[NSMutableData alloc] init];
			
			[asyncResultData appendData:data];
		}
	}
	@catch (NSException * e)
	{
		//cancel connection
		[asyncConnection cancel];

		[asyncConnection release];
		asyncConnection = nil;
		
		//send NSError description to async result handler
		[asyncResultHandler performSelector:asyncResultSelector 
								 withObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
																				 [NSNumber numberWithInt:0], 
																				 [e description], 
																				 nil] 
																		forKeys:[NSArray arrayWithObjects:
																				 kHTTP_ASYNC_RESULT_CODE, 
																				 kHTTP_ASYNC_RESULT_ERRORSTR, 
																				 nil]]];		
		
		[asyncResponse release];
		asyncResponse = nil;
		
		[asyncResultHandler release];
		asyncResultHandler = nil;
		
		asyncResultSelector = nil;
		
		[asyncResultData release];
		asyncResultData = nil;

		DebugLog(@"exception while receiving async data: %@", [e description]);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@synchronized(self)
	{
		//send asyncResultData to async result handler
		int statusCode = [(NSHTTPURLResponse*)asyncResponse statusCode];
		NSString* mime = [asyncResponse MIMEType];
		NSString* encoding = [asyncResponse textEncodingName];
		NSDictionary* headerFields = [(NSHTTPURLResponse*)asyncResponse allHeaderFields];
		[asyncResultHandler performSelector:asyncResultSelector 
								 withObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
																				 [NSNumber numberWithInt:statusCode], 
																				 asyncResultData, 
																				 mime == nil ? @"" : mime, 
																				 encoding == nil ? @"" : encoding, 
																				 headerFields == nil ? [NSDictionary dictionary] : headerFields,
																				 nil] 
																		forKeys:[NSArray arrayWithObjects:
																				 kHTTP_ASYNC_RESULT_CODE, 
																				 kHTTP_ASYNC_RESULT_DATA, 
																				 kHTTP_ASYNC_RESULT_CONTENTTYPE, 
																				 kHTTP_ASYNC_RESULT_CHARENCODING, 
																				 kHTTP_ASYNC_RESULT_HEADERFIELDS,
																				 nil]]];
		
		[asyncConnection release];
		asyncConnection = nil;
		
		[asyncResponse release];
		asyncResponse = nil;
		
		[asyncResultHandler release];
		asyncResultHandler = nil;
		
		asyncResultSelector = nil;
		
		[asyncResultData release];
		asyncResultData = nil;
	}
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
	//send NSError description to async result handler
	[asyncResultHandler performSelector:asyncResultSelector 
							 withObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
																			 [NSNumber numberWithInt:0], 
																			 [error localizedDescription], 
																			 nil] 
																	forKeys:[NSArray arrayWithObjects:
																			 kHTTP_ASYNC_RESULT_CODE, 
																			 kHTTP_ASYNC_RESULT_ERRORSTR, 
																			 nil]]];

	[asyncConnection release];
	asyncConnection = nil;
	
	[asyncResponse release];
	asyncResponse = nil;
	
	[asyncResultHandler release];
	asyncResultHandler = nil;
	
	asyncResultSelector = nil;
	
	[asyncResultData release];
	asyncResultData = nil;
	
	DebugLog(@"connection did fail with error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark etc.

- (void)dealloc
{
	[asyncConnection release];
	[asyncResultHandler release];
	[asyncResponse release];
	[asyncResultData release];
	
	[super dealloc];
}

@end
