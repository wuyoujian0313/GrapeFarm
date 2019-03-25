//
//  UIColor+Utility.m
//  BaiduTong
//
//  Created by wuyj on 14-11-24.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "UIColor+Utility.h"

@implementation UIColor (Utility)

+ (UIColor *)colorWithHex:(NSInteger)hex {
    
   return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                    green:((float)((hex & 0x00FF00) >> 8))/255.0
                     blue:((float)(hex & 0x0000FF))/255.0
                    alpha:1.0];
}

+ (UIColor*)colorWithHexString:(NSString*)hexString
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]]scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]]scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

@end
