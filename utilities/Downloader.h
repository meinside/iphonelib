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
//  Downloader.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 02. 21.
//
//  last update: 11.02.22.
//

#pragma once
#import <Foundation/Foundation.h>

#define DOWNLOAD_HTTP_METHOD @"GET"
#define DOWNLOAD_TIMEOUT_INTERVAL 10.0


@protocol DownloaderDelegate;

@interface Downloader : NSObject {

	NSURLConnection* connection;
	
	NSString* localFilepath;
	NSFileHandle* localFileHandle;
	
	long long totalFileBytes;

	id<DownloaderDelegate> delegate;
	
	BOOL isDownloading;
}

- (void)download:(NSString*)remotePath 
		 toLocal:(NSString*)localPath;

- (void)cancelDownload;

@property (assign) id<DownloaderDelegate> delegate;
@property (nonatomic, retain) NSFileHandle* localFileHandle;
@property (nonatomic, copy) NSString* localFilepath;

@end

@protocol DownloaderDelegate <NSObject>

- (void)downloadStarted;

- (void)downloadProgress:(long long)downloadedBytes 
				   total:(long long)totalBytes;

- (void)downloadSucceeded;

- (void)downloadFailed:(NSError*)error;

- (void)downloadCanceled;

@end

