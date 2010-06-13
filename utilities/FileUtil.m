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
//  FileUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 10.06.13.
//

#import "FileUtil.h"


@implementation FileUtil

#pragma mark -
#pragma mark file-related functions

+ (NSString*)pathForPathType:(PathType)type
{
	NSSearchPathDirectory directory;
	switch(type)
	{
		case PathTypeDocument:
			directory = NSDocumentDirectory;
			break;
		case PathTypeLibrary:
			directory = NSLibraryDirectory;
			break;
		case PathTypeBundle:
			return [[NSBundle mainBundle] bundlePath];
			break;
		case PathTypeResource:
			return [[NSBundle mainBundle] resourcePath];
			break;
		case PathTypeTemp:
			return NSTemporaryDirectory();
			break;
		default:
			return nil;
	}
	NSArray* directories = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
	if(directories != nil && [directories count] > 0)
		return [directories objectAtIndex:0];
	return nil;
}

+ (NSString*)pathOfFile:(NSString*)filename withPathType:(PathType)type
{
	return [[self pathForPathType:type] stringByAppendingPathComponent:filename];
}

+ (BOOL)fileExistsAtPath:(NSString*)path
{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)copyFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath
{
	NSError* error;
	return [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
}

+ (BOOL)deleteFileAtPath:(NSString*)path
{
	NSError* error;
	return [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path withAttributes:(NSDictionary*)attributes
{
	NSError* error;
	return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:&error];
}

+ (BOOL)createFileAtPath:(NSString*)path withData:(NSData*)data andAttributes:(NSDictionary*)attr
{
	return [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:attr];
}

+ (NSData*)dataFromPath:(NSString *)path
{
	return [[NSFileManager defaultManager] contentsAtPath:path];
}

+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path
{
	NSError* error;
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
}

@end
