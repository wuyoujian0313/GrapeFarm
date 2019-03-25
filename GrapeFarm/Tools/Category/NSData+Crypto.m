//
//  NSData+Crypto.m
//  Encrypt
//
//  Created by wuyj on 15/7/3.
//  Copyright (c) 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Crypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>


@implementation NSData (Crypto)

// 解密方法
- (NSData *)DES3DecryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    size_t bufferPtrSize = ([self length] +kCCBlockSize3DES) & ~(kCCBlockSize3DES-1);
    uint8_t*bufferPtr = malloc( bufferPtrSize *sizeof(uint8_t));
    // java侧不足位是补充0的
    memset((void*)bufferPtr,0x0, bufferPtrSize);
    
    const void*vkey = (const void*)[key UTF8String];
    const void*vinitVec = (const void*) [Iv UTF8String];
    
    size_t movedBytes =0;
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                      kCCAlgorithm3DES,
                      kCCOptionPKCS7Padding,
                      vkey,
                      kCCKeySize3DES,
                      vinitVec,
                      [self bytes],
                      [self length],
                      (void*)bufferPtr,
                      bufferPtrSize,
                      &movedBytes);
    
    if (ccStatus == kCCSuccess) {
        NSData *result = [NSData dataWithBytes:(const void*)bufferPtr length:(NSUInteger)movedBytes];
        free(bufferPtr);
        return result;
    }
    free(bufferPtr);
    return nil;
}

//加密方法
- (NSData *)DES3EncryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    size_t bufferPtrSize = ([self length] +kCCBlockSize3DES) & ~(kCCBlockSize3DES-1);
    uint8_t *bufferPtr = malloc(bufferPtrSize *sizeof(uint8_t));
    memset((void*)bufferPtr,0x0, bufferPtrSize);
    
    const void* vkey = (const void*) [key UTF8String];
    const void* vinitVec = (const void*) [Iv UTF8String];
    
    size_t movedBytes = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                      kCCAlgorithm3DES,
                      kCCOptionPKCS7Padding,
                      vkey,
                      kCCKeySize3DES,
                      vinitVec,
                      [self bytes],
                      [self length],
                      (void*)bufferPtr,
                      bufferPtrSize,
                      &movedBytes);
    
    if (ccStatus == kCCSuccess) {
        NSData* encryptData = [NSData dataWithBytes:(const void*)bufferPtr length:(NSUInteger)movedBytes];
        free(bufferPtr);
        return encryptData;
    }
    free(bufferPtr);
    return nil;
}


- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData* encryptData =[NSData dataWithBytes:buffer length:numBytesEncrypted];
        free(buffer);
        return encryptData;
    }
    free(buffer);
    return nil;
}


- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv {
    
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [Iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData* decryptedData = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        free(buffer);
        return decryptedData;
    }
    free(buffer);
    return nil;
}

- (NSString*)md5String {
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, r);
    NSString *md5 = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    
    return md5;
}

#define CHUNK_SIZE 1024

+ (NSString *)fileMD5:(NSString*)path {
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    if(handle == nil)
        return nil;
    
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    // 分块读取数据
    NSData* filedata;
    do {
        
        filedata = [handle readDataOfLength:CHUNK_SIZE];
        
        //调用系统底层函数，无法避免32->64
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshorten-64-to-32"
        CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);
#pragma clang diagnostic pop
        
    }
    
    while([filedata length]);
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    [handle closeFile];
    
    NSMutableString *hash = [NSMutableString string];
    
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++) {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

- (NSData*)base64EncodeData {
    
    NSData *stringData =[self base64EncodedDataWithOptions:0];
    return stringData;
}

- (NSData*)base64DecodeData {
    NSData *stringBase64Data = [[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return stringBase64Data;
}

- (NSString*)base64EncodeString {
    NSString *string = [self base64EncodedStringWithOptions:0];
    return string;
}

- (NSString*)base64DecodeString {
    
    NSData *stringData = [self base64DecodeData];
    return [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
}

- (NSData *) SHA1Hash {
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    (void) CC_SHA1( [self bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA1_DIGEST_LENGTH] );
}

- (NSData *) SHA224Hash {
    unsigned char hash[CC_SHA224_DIGEST_LENGTH];
    (void) CC_SHA224( [self bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA224_DIGEST_LENGTH] );
}

- (NSData *) SHA256Hash {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    (void) CC_SHA256( [self bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA256_DIGEST_LENGTH] );
}

- (NSData *) SHA384Hash {
    unsigned char hash[CC_SHA384_DIGEST_LENGTH];
    (void) CC_SHA384( [self bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA384_DIGEST_LENGTH] );
}

- (NSData *) SHA512Hash {
    unsigned char hash[CC_SHA512_DIGEST_LENGTH];
    (void) CC_SHA512( [self bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA512_DIGEST_LENGTH] );
}

- (NSString *)byteToHex {
    NSUInteger len = [self length];
    char *chars = (char *)[self bytes];
    NSMutableString *hexString = [[NSMutableString alloc]init];
    for (NSUInteger i=0; i<len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]]];
    }
    return hexString;
}

+ (NSData *)hexToData:(NSString *)hexString {
    const char *chars = [hexString UTF8String];
    int i = 0;
    int len = (int)hexString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i<len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

@end

