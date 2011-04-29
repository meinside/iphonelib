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
//  Downloader.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 02. 21.
//
//  last update: 11.04.29.
//

#import "Downloader.h"

#import "Logging.h"


@implementation Downloader

@synthesize localFileHandle;
@synthesize localFilepath;
@synthesize delegate;

- (id)init
{
	if((self = [super init]))
	{
		isDownloading = NO;
	}
	return self;
}

- (void)dealloc
{
	if(isDownloading)
		[self cancelDownload];
	
	[localFilepath release];
	[localFileHandle release];

	[super dealloc];
}


#pragma mark -
#pragma mark download function

- (void)download:(NSString*)remotePath 
		 toLocal:(NSString*)localPath
{
	if(isDownloading)
	{
		DebugLog(@"already downloading");
		return;
	}
	
	isDownloading = YES;
	
	self.localFilepath = localPath;
	
	totalFileBytes = NSURLResponseUnknownLength;

	@synchronized(self)
	{
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:remotePath]];
		[request setHTTPMethod:DOWNLOAD_HTTP_METHOD];
		[request setTimeoutInterval:DOWNLOAD_TIMEOUT_INTERVAL];
		
		connection = [[NSURLConnection alloc] initWithRequest:request
													 delegate:self
											 startImmediately:YES];
	}

	DebugLog(@"will download: '%@' to: '%@'", remotePath, localPath);

	[delegate downloadStarted];
}

- (void)cancelDownload
{
	DebugLog(@"canceling download");

	@synchronized(self)
	{
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	isDownloading = NO;
	
	[delegate  downloadCanceled];
}


#pragma mark -
#pragma mark NSURLConnection delegate functions

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
	if(totalFileBytes == NSURLResponseUnknownLength)
		totalFileBytes = [response expectedContentLength];
	
	DebugLog(@"total number of bytes: %qi", totalFileBytes);

	[[NSFileManager defaultManager] createFileAtPath:localFilepath 
											contents:nil 
										  attributes:nil];

	self.localFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:localFilepath];
	[localFileHandle seekToEndOfFile];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
	[localFileHandle seekToEndOfFile];
	[localFileHandle writeData:data];

	[delegate downloadProgress:[localFileHandle offsetInFile] 
						 total:totalFileBytes];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
	[localFileHandle closeFile];
	
	[conn release];
	conn = nil;
	
	isDownloading = NO;
	
	[delegate downloadSucceeded];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
	[localFileHandle closeFile];
	
	[conn release];
	conn = nil;
	
	isDownloading = NO;
	
	DebugLog(@"download failed with error: %@ / %@", [error localizedDescription], [error localizedFailureReason]);
	
	[delegate downloadFailed:error];
}

@end
