//
//  NSData+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 4.
//
//  last update: 13.03.28.
//

#pragma once
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>


@interface NSData (NSDataExtension) 

/**
 * do AES encryption
 *
 * key:
 * iv: initial vector (if not nil: CBC mode / nil: ECB mode)
 */
- (NSData*)aesEncryptWithKey:(NSString *)key
				initialVector:(NSString*)iv;

/**
 * do AES decryption
 *
 * key:
 * iv: initial vector (if not nil: CBC mode / nil: ECB mode)
 */
- (NSData*)aesDecryptWithKey:(NSString *)key
				initialVector:(NSString*)iv;

/**
 * do DES encryption
 *
 * key:
 * iv: initial vector (if not nil: CBC mode / nil: ECB mode)
 */
- (NSData*)desEncryptWithKey:(NSString *)key
			   initialVector:(NSString*)iv;

/**
 * do DES decryption
 *
 * key:
 * iv: initial vector (if not nil: CBC mode / nil: ECB mode)
 */
- (NSData*)desDecryptWithKey:(NSString *)key
			   initialVector:(NSString*)iv;

/**
 * base64 encode
 */
- (NSString*)base64EncodedString;

/**
 * dump to to hex(byte array) format
 */
- (NSString*)hexDump;

@end
