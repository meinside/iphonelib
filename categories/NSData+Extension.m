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
//  NSData+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 4.
//
//  last update: 10.07.21.
//

#import "NSData+Extension.h"

#import "Base64Transcoder.h"
#import "Logging.h"


@implementation NSData (NSDataExtension)

#pragma mark -
#pragma mark AES encrypt/decrypt functions

- (NSData*) aesEncryptWithKey:(NSString *)key initialVector:(NSString*)iv
{
	int keyLength = [key length];
	if(keyLength != kCCKeySizeAES128 && keyLength != kCCKeySizeAES192 && keyLength != kCCKeySizeAES256)
	{
		DebugLog(@"key length is not 128/192/256-bits long");

		return nil;
	}
	
	char keyBytes[keyLength + 1];
	bzero(keyBytes, sizeof(keyBytes));
	[key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];

	size_t numBytesEncrypted = 0;
	size_t encryptedLength = [self length] + kCCBlockSizeAES128;
	char* encryptedBytes = malloc(encryptedLength);
	
	CCCryptorStatus result = CCCrypt(kCCEncrypt, 
									 kCCAlgorithmAES128 , 
									 (iv == nil ? kCCOptionECBMode | kCCOptionPKCS7Padding : kCCOptionPKCS7Padding),	//default: CBC (when initial vector is supplied)
									 keyBytes, 
									 keyLength, 
									 iv,
									 [self bytes], 
									 [self length],
									 encryptedBytes, 
									 encryptedLength,
									 &numBytesEncrypted);

	if(result == kCCSuccess)
		return [NSData dataWithBytesNoCopy:encryptedBytes length:numBytesEncrypted];

	free(encryptedBytes);
	return nil;
}

- (NSData*) aesDecryptWithKey:(NSString *)key initialVector:(NSString*)iv
{
	int keyLength = [key length];
	if(keyLength != kCCKeySizeAES128 && keyLength != kCCKeySizeAES192 && keyLength != kCCKeySizeAES256)
	{
		DebugLog(@"key length is not 128/192/256-bits long");

		return nil;
	}

	char keyBytes[keyLength+1];
	bzero(keyBytes, sizeof(keyBytes));
	[key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];

	size_t numBytesDecrypted = 0;
	size_t decryptedLength = [self length] + kCCBlockSizeAES128;
	char* decryptedBytes = malloc(decryptedLength);
	
	CCCryptorStatus result = CCCrypt(kCCDecrypt, 
									 kCCAlgorithmAES128 , 
									 (iv == nil ? kCCOptionECBMode | kCCOptionPKCS7Padding : kCCOptionPKCS7Padding),	//default: CBC (when initial vector is supplied)
									 keyBytes, 
									 keyLength, 
									 iv,
									 [self bytes], 
									 [self length],
									 decryptedBytes, 
									 decryptedLength,
									 &numBytesDecrypted);

	if(result == kCCSuccess)
		return [NSData dataWithBytesNoCopy:decryptedBytes length:numBytesDecrypted];
	
	free(decryptedBytes);
	return nil;
}

#pragma mark -
#pragma mark Base64 encoding

- (NSString*) base64EncodedString
{
	@try 
	{
		size_t base64EncodedLength = EstimateBas64EncodedDataSize([self length]);
		char base64Encoded[base64EncodedLength];
		if(Base64EncodeData([self bytes], [self length], base64Encoded, &base64EncodedLength))
		{
			NSData* encodedData = [NSData dataWithBytes:base64Encoded length:base64EncodedLength];
			NSString* base64EncodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
			return [base64EncodedString autorelease];
		}
	}
	@catch (NSException * e)
	{
		//do nothing
		DebugLog(@"exception: %@", [e reason]);
	}
	return nil;
}

#pragma mark -
#pragma mark functions for debug purpose

- (NSString*)hexDump
{
    unsigned char *inbuf = (unsigned char *)[self bytes];	
	NSMutableString* stringBuffer = [NSMutableString string];
    for (int i=0; i<[self length]; i++)
    {
        if (i != 0 && i % 16 == 0)
			[stringBuffer appendString:@"\n"];
		[stringBuffer appendFormat:@"0x%02X, ", inbuf[i]];
    }
	return stringBuffer;
}

@end
