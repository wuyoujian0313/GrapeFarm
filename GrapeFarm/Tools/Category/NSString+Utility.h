//
//  NSString+Utility.h
//
//
//  Created by wuyj on 14/11/21.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (Utility)


- (CGSize)sizeWithFontCompatible:(UIFont *_Nonnull)font;
- (CGSize)sizeWithFontCompatible:(UIFont *_Nonnull)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;


- (NSString*_Nullable)md5EncodeUpper:(BOOL)upper;
+ (NSString*_Nullable)UUID;
+ (NSString*_Nullable)stringFormatPointer:(void*_Nonnull)pointer;
+ (NSString*_Nullable)timeShortFormat:(int)seconds;
+ (NSString*_Nullable)dateAndTimeFormat;

- (BOOL)isValidateEmail;
- (BOOL)isValidateMobile;
- (BOOL)isValidateURL;
- (BOOL)isHaveChinese;
- (NSString*_Nullable)timeStringToChineseString;

- (NSString*_Nullable)urlEncodingWithStringEncoding:(NSStringEncoding)encoding;

- (NSString*_Nullable)base64EncodeString;
- (NSString*_Nullable)base64DecodeString;
- (NSData*_Nullable)base64EncodeData;
- (NSData*_Nullable)base64DecodeData;

+ (NSString*_Nullable)generateZH_string;

- (NSData *_Nullable) SHA1Hash;
- (NSData *_Nullable) SHA224Hash;
- (NSData *_Nullable) SHA256Hash;
- (NSData *_Nullable) SHA384Hash;
- (NSData *_Nullable) SHA512Hash;

- (NSString *_Nullable)byteToHex;
- (NSString *_Nullable)hexToString;
- (NSString *_Nullable)paramEncodeForJs;
@end
