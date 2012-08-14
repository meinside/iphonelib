//
//  FileUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 12.08.14.
//

#include <sys/xattr.h>

#import "FileUtil.h"

#import "Logging.h"


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
		case PathTypeCache:
			directory = NSCachesDirectory;
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

//referenced: http://stackoverflow.com/questions/2188469/calculate-the-size-of-a-folder
+ (unsigned long long int)sizeOfFolderPath:(NSString *)path
{
    unsigned long long int totalSize = 0;

	NSEnumerator* enumerator = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil] objectEnumerator];	
    NSString* fileName;
    while((fileName = [enumerator nextObject]))
	{
		totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil] fileSize];
    }
	
    return totalSize;	
}

//referenced: http://longweekendmobile.com/2011/11/11/keeping-but-not-backing-up-downloaded-data-in-ios5/
+ (BOOL)skipBackupAtPath:(NSString*)path
{
	const char* filePath = [path fileSystemRepresentation];
	const char* attrName = "com.apple.MobileBackup";
	u_int8_t attrValue = 1;
	
	return setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0) == 0;
}

@end
