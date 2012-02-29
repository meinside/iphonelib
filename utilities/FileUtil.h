//
//  FileUtil.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 12.01.13.
//

#pragma once
#import <Foundation/Foundation.h>


@interface FileUtil : NSObject {

}

typedef enum _PathType {
	PathTypeLibrary,
	PathTypeDocument,
	PathTypeResource,
	PathTypeBundle,
	PathTypeTemp,
	PathTypeCache,
} PathType;


+ (NSString*)pathForPathType:(PathType)type;

+ (NSString*)pathOfFile:(NSString*)filename withPathType:(PathType)type;

+ (BOOL)fileExistsAtPath:(NSString*)path;

+ (BOOL)copyFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath;

+ (BOOL)deleteFileAtPath:(NSString*)path;

+ (BOOL)createDirectoryAtPath:(NSString *)path withAttributes:(NSDictionary*)attributes;

+ (BOOL)createFileAtPath:(NSString*)path withData:(NSData*)data andAttributes:(NSDictionary*)attr;

+ (NSData*)dataFromPath:(NSString*)path;

+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path;

+ (unsigned long long int)sizeOfFolderPath:(NSString *)path;


@end
