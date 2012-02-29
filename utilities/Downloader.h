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

