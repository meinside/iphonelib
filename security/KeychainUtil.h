//
//  KeychainUtil.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 19.
//
//  last update: 10.01.16.
//

#pragma once
#import <Foundation/Foundation.h>

//needs: Security.framework

@interface KeychainUtil : NSObject {

}

+ (BOOL)saveGenericPasswd:(NSData*)data forAccount:(NSString*)account service:(NSString*)service passwdKey:(NSString*)key overwrite:(BOOL)overwrite;

+ (BOOL)updateGenericPasswd:(NSData*)data forAccount:(NSString*)account service:(NSString*)service passwdKey:(NSString*)key;

+ (NSString*)loadPasswdStringForAccount:(NSString*)account service:(NSString*)service passwdKey:(NSString*)key;

+ (NSData*)loadPasswdDataForAccount:(NSString*)account service:(NSString*)service passwdKey:(NSString*)key;

+ (BOOL)deleteGenericPasswdForAccount:(NSString*)account service:(NSString*)service passwdKey:(NSString*)key;

+ (BOOL)genericPasswdExistsForAccount:(NSString*)account service:(NSString*)service passwdKey:(NSString*)key;


+ (NSData*)dataFromDictionary:(NSMutableDictionary*)dic;

+ (NSMutableDictionary*)dictionaryFromData:(NSData*)data;


+ (NSString*)fetchStatus:(OSStatus)status;


+ (void)resetCredentials;

+ (void)dumpCredentials;

@end
