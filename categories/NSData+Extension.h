//
//  NSData+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 4.
//
//  last update: 10.07.21.
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
- (NSData*) aesEncryptWithKey:(NSString *)key initialVector:(NSString*)iv;

/**
 * do AES decryption
 *
 * key:
 * iv: initial vector (if not nil: CBC mode / nil: ECB mode)
 */
- (NSData*) aesDecryptWithKey:(NSString *)key initialVector:(NSString*)iv;

/**
 * base64 encode
 */
- (NSString*) base64EncodedString;

/**
 * dump to to hex(byte array) format
 */
- (NSString*)hexDump;

@end
