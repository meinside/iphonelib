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
