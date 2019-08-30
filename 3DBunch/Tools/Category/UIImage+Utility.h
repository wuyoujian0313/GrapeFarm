//
//  UIImage+Utility.h
//  
//
//  Created by wuyj on 14-12-1.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize;

// 截图
+ (UIImage *)screenShotImage:(UIView*)view;

// 生成二维码
+ (UIImage *)generateQRCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height;
// 二维码识别
- (NSArray *)recognitionQRCodeFromImage;

// 生成条形码
+ (UIImage *)generateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height;



@end
