//
//  CryptoUtilTests.m
//  iPhoneLib
//
//  Created by Louis Vera on 7/14/12.
//  Copyright (c) 2012 Louis Vera. All rights reserved.
//

#import "CryptoUtilTests.h"
#import "CryptoUtil.h"

@implementation CryptoUtilTests

-(void)testEncryptWith64PublicKey {
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSData * modulus = [NSData dataWithContentsOfURL:[bundle URLForResource:@"modulus64" withExtension:@"bin"]];
    uint8_t exp[] = { 0x01, 0x00, 0x01 };
    NSData * exponent = [NSData dataWithBytes:&exp length:sizeof(exp)];
    NSData * publicKeyData = [CryptoUtil generateRSAPublicKeyWithModulus:modulus exponent:exponent];
    STAssertNotNil(publicKeyData, @"No key data returned");
    NSString * tag = @"com.3spark.test.public.modulus64";
    STAssertTrue([CryptoUtil saveRSAPublicKey:publicKeyData appTag:tag overwrite:YES], @"Saving key failed");
    SecKeyRef publicKey = [CryptoUtil loadRSAPublicKeyRefWithAppTag:tag];
    STAssertFalse(NULL == publicKey, @"Public key is null");
    NSData * actual = [CryptoUtil encryptString:@"test" RSAPublicKey:publicKey padding:kSecPaddingPKCS1];
    STAssertNotNil(actual, @"Encrypted data is nil");
    CFRelease(publicKey);
}

-(void)testEncryptWith512PublicKey {
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSData * modulus = [NSData dataWithContentsOfURL:[bundle URLForResource:@"modulus512" withExtension:@"bin"]];
    uint8_t exp[] = { 0x01, 0x00, 0x01 };
    NSData * exponent = [NSData dataWithBytes:&exp length:sizeof(exp)];
    NSData * publicKeyData = [CryptoUtil generateRSAPublicKeyWithModulus:modulus exponent:exponent];
    STAssertNotNil(publicKeyData, @"No key data returned");
    NSString * tag = @"com.3spark.test.public.modulus512";
    STAssertTrue([CryptoUtil saveRSAPublicKey:publicKeyData appTag:tag overwrite:YES], @"Saving key failed");
    SecKeyRef publicKey = [CryptoUtil loadRSAPublicKeyRefWithAppTag:tag];
    STAssertFalse(NULL == publicKey, @"Public key is null");
    NSData * actual = [CryptoUtil encryptString:@"test" RSAPublicKey:publicKey padding:kSecPaddingPKCS1];
    STAssertNotNil(actual, @"Encrypted data is nil");
    CFRelease(publicKey);
}

-(void)testEncryptWith1024PublicKey {
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSData * modulus = [NSData dataWithContentsOfURL:[bundle URLForResource:@"modulus1024" withExtension:@"bin"]];
    uint8_t exp[] = { 0x01, 0x00, 0x01 };
    NSData * exponent = [NSData dataWithBytes:&exp length:sizeof(exp)];
    NSData * publicKeyData = [CryptoUtil generateRSAPublicKeyWithModulus:modulus exponent:exponent];
    STAssertNotNil(publicKeyData, @"No key data returned");
    NSString * tag = @"com.3spark.test.public.modulus1024";
    STAssertTrue([CryptoUtil saveRSAPublicKey:publicKeyData appTag:tag overwrite:YES], @"Saving key failed");
    SecKeyRef publicKey = [CryptoUtil loadRSAPublicKeyRefWithAppTag:tag];
    STAssertFalse(NULL == publicKey, @"Public key is null");
    NSData * actual = [CryptoUtil encryptString:@"test" RSAPublicKey:publicKey padding:kSecPaddingPKCS1];
    STAssertNotNil(actual, @"Encrypted data is nil");
    CFRelease(publicKey);
}

@end
