//
//  NSString+Utility.m
//
//
//  Created by wuyj on 14/11/21.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "NSString+Utility.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Utility)


- (CGSize)sizeWithFontCompatible:(UIFont *)font
{
    if([self respondsToSelector:@selector(sizeWithAttributes:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font};
        CGSize stringSize = [self sizeWithAttributes:dictionaryAttributes];
        return CGSizeMake(ceil(stringSize.width), ceil(stringSize.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [self sizeWithFont:font];
#pragma clang diagnostic pop
        
    }
}

- (CGSize)sizeWithFontCompatible:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font,};
        CGRect stringRect = [self boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:dictionaryAttributes
                                               context:nil];
        
        return CGSizeMake(ceil(stringRect.size.width), ceil(stringRect.size.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
}

-(NSString*)md5EncodeUpper:(BOOL)upper {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result);
    
    NSString *formatString = @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x";
    if (upper) {
        formatString = @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X";
    }
    
    return [NSString stringWithFormat:
            formatString,
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

+(NSString *)UUID {
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    CFRelease(uuid);
    CFRelease(cfstring);
    
    return [NSString stringWithFormat:
                 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                 result[0], result[1], result[2], result[3],
                 result[4], result[5], result[6], result[7],
                 result[8], result[9], result[10], result[11],
                 result[12], result[13], result[14], result[15],
                 (unsigned long)(arc4random() % NSUIntegerMax)];
}

+(NSString*)stringFormatPointer:(void*)pointer
{
//    if (sizeof(void*)<=sizeof(int32_t)) {
//        return [NSString stringWithFormat:@"%i", (uint32_t)pointer];
//    }
    
    return [NSString stringWithFormat:@"%llu", (uint64_t)pointer];
}

+(NSString*)dateAndTimeFormat {
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *str= [outputFormatter stringFromDate:[NSDate date]];
    return str;
}

+(NSString*)timeShortFormat:(int)seconds
{
    int h = seconds / 3600;
    int m = (seconds/60) % 60;
    int s = seconds % 60;
    if (h>0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", h, m, s];
    }
    
    return [NSString stringWithFormat:@"%d:%02d", m, s];
}

-(BOOL)isValidateEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:self];
}

-(BOOL)isValidateURL {
    NSString *urlRegex = @"(((http[s]{0,1}|ftp)://)[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlPredicate evaluateWithObject:self];
}


-(BOOL)isValidateMobile {
    //手机号以13， 15，18，17开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$";
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phonePredicate evaluateWithObject:self];
}


-(BOOL)isHaveChinese {
    
    for(NSInteger i = 0; i < [self length];i++) {
        int c = [self characterAtIndex:i];
        if( c > 0x4e00 && c < 0x9fff){
            return YES;
        }
    } return NO;
}

- (NSString*)timeStringToChineseString {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayString = [outputFormatter stringFromDate:[NSDate date]];
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
    NSString *yesterdayString = [outputFormatter stringFromDate:yesterday];
    
    if ([self isEqualToString:todayString]) {
        return @"今天";
    } else if ([self isEqualToString:yesterdayString]) {
        return @"昨天";
    }
    
    return self;
}

static NSString * const kCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

-(NSString*)urlEncodingWithStringEncoding:(NSStringEncoding)encoding {
    static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

- (NSString*)base64EncodeString {
    
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [stringData base64EncodedStringWithOptions:0];
    
    return stringBase64;
}

- (NSString*)base64DecodeString {
    NSData *stringBase64Data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSString *stringBase64 = [[NSString alloc] initWithData:stringBase64Data encoding:NSUTF8StringEncoding];
    return stringBase64;
}

- (NSData*)base64EncodeData  {
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    return [stringData base64EncodedDataWithOptions:0];
}

- (NSData*)base64DecodeData {
    NSData *stringBase64Data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return stringBase64Data;
}

+ (NSString*)generateZH_string {
    NSString *s = @"湖南亚信软件有限公司陕西移动CRM支撑团队";
    
    NSString *Zh_string = @"";
    for (NSUInteger i = 0; i < 10; i++) {
        NSUInteger index = (NSUInteger)(arc4random() % [s length]);
        Zh_string = [Zh_string stringByAppendingString:[s substringWithRange:NSMakeRange(index, 1)]];
    }
    
    return Zh_string;
}

- (NSData *) SHA1Hash {
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    (void) CC_SHA1( [data bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA1_DIGEST_LENGTH] );
}

- (NSData *) SHA224Hash {
    unsigned char hash[CC_SHA224_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    (void) CC_SHA224( [data bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA224_DIGEST_LENGTH] );
}

- (NSData *) SHA256Hash {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    (void) CC_SHA256( [data bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA256_DIGEST_LENGTH] );
}

- (NSData *) SHA384Hash {
    unsigned char hash[CC_SHA384_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    (void) CC_SHA384( [data bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA384_DIGEST_LENGTH] );
}

- (NSData *) SHA512Hash {
    unsigned char hash[CC_SHA512_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    (void) CC_SHA512( [data bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_SHA512_DIGEST_LENGTH] );
}

- (NSString *)byteToHex {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[data bytes];

    NSString *hexString = @"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1) {
            hexString = [NSString stringWithFormat:@"%@0%@",hexString,newHexStr];
        } else {
            hexString = [NSString stringWithFormat:@"%@%@",hexString,newHexStr];
        }
    }   
    return hexString;
}

- (NSString *)hexToString {
    char *myBuffer = (char *)malloc((int)[self length] / 2 + 1);
    bzero(myBuffer, [self length] / 2 + 1);
    for (int i = 0; i < [self length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [self substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
    return unicodeString;
}

- (NSString * _Nullable )paramEncodeForJs {
    if ([self length] > 0) {
        NSUInteger length = [self length];
        NSString *temp = @"";
        for (NSUInteger i = 0; i < length; i ++) {
            NSString *c = [self substringWithRange:NSMakeRange(i, 1)];
            if ([c isEqualToString:@"\b"]) {
                temp = [temp stringByAppendingString:@"\\b"];
            } else if ([c isEqualToString:@"\t"]) {
                temp = [temp stringByAppendingString:@"\\t"];
            } else if ([c isEqualToString:@"\n"]) {
                temp = [temp stringByAppendingString:@"\\n"];
            } else if ([c isEqualToString:@"\f"]) {
                temp = [temp stringByAppendingString:@"\\f"];
            } else if ([c isEqualToString:@"\r"]) {
                temp = [temp stringByAppendingString:@"\\r"];
            } else if ([c isEqualToString:@"\'"]) {
                temp = [temp stringByAppendingString:@"\\\'"];
            } else if ([c isEqualToString:@"\\"]) {
                temp = [temp stringByAppendingString:@"\\\\"];
            } else {
                temp = [temp stringByAppendingString:c];
            }
        }
        
        return temp;
    }
    
    return @"";
}

@end
