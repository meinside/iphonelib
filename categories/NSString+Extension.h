//
//  NSString+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 10. 11.
//
//  last update: 12.10.22.
//

#pragma once
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>


@interface NSString (NSStringExtension)

/**
 * checks if this string contains any of Korean, Chinese, or Japanese characters
 */
- (BOOL)containsCJK;

/**
 * returns urlencoded value of this string
 */
- (NSString*)urlencodedValue;

/**
 * returns urldecoded value of this string
 */
- (NSString*)urldecodedValue;

/**
 * returns HMAC-SHA1 digest value of this string
 */
- (NSString*)hmacSha1DigestWithKey:(NSString*)secret;

/**
 * returns MD5 digest value of this string
 */
- (NSString*)md5Digest;

/**
 * returns Base64 decoded bytes
 */
- (NSData*)base64DecodedBytes;

@end
