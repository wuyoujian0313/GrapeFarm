//
//  NSData+Crypto.h
//  Encrypt
//
//  Created by wuyj on 15/7/3.
//  Copyright (c) 2015年 wuyj. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSData (Crypto)

// !!!!!!!!!! key & Iv都是16位的
- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv;   //加密
- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv;   //解密

// !!!!!!!!!! DES,key是24位字符 Iv的长度是8位字符
- (NSData *)DES3EncryptWithKey:(NSString *)key gIv:(NSString *)Iv;   //加密
- (NSData *)DES3DecryptWithKey:(NSString *)key gIv:(NSString *)Iv;   //解密

// md5加密
- (NSString*)md5String;

// 文件的md5加密校验
+ (NSString *)fileMD5:(NSString*)path;

- (NSData*)base64EncodeData;
- (NSData*)base64DecodeData;
- (NSString*)base64EncodeString;
- (NSString*)base64DecodeString;

- (NSData *) SHA1Hash;
- (NSData *) SHA224Hash;
- (NSData *) SHA256Hash;
- (NSData *) SHA384Hash;
- (NSData *) SHA512Hash;

- (NSString *)byteToHex;
+ (NSData *)hexToData:(NSString *)hexString;




@end
