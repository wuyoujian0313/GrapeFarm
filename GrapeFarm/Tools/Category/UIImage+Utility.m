//
//  UIImage+Utility.m
//  BaiduTong
//
//  Created by wuyj on 14-12-1.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "UIImage+Utility.h"
#import "UIImage+ResizeMagick.h"

@implementation UIImage (Utility)

+ (UIImage *)imageFromColor:(UIColor *)color {
   return [[self class] imageFromColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//把较大的图片重新调整大小
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize {
    //If scaleFactor is not touched, no scaling will occur
    // CGFloat scaleFactor = 1.0;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    //Deciding which factor to use to scale the image (factor = targetSize / imageSize)
    //    if (image.size.width > targetSize.width || image.size.height > targetSize.height)
    //       if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
    //           scaleFactor = targetSize.height / image.size.height; // scale to fit heigth.
    
    if (image.size.width > targetSize.width || image.size.height > targetSize.height) {
        CGFloat factorWidth = width / targetSize.width;
        CGFloat factorHeight = height / targetSize.height;
        if (factorWidth > factorHeight) {
            width = targetSize.width;
            height = height / factorWidth;
        }else{
            height = targetSize.height;
            width = width / factorHeight;
        }
    }
    
    if (NULL != &UIGraphicsBeginImageContextWithOptions && width>0)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 2.0);
    else
        UIGraphicsBeginImageContext(targetSize);
    
    //Creating the rect where the scaled image is drawn in
    CGRect rect = CGRectMake(0,
                             0,
                             width, height);
    
    //Draw the image into the rect
    [image drawInRect:rect];
    
    //Saving the image, ending image context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

// 截图
+ (UIImage *)screenShotImage:(UIView*)view {
    
    //创建图片
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //截取当前的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// 生成二维码图片
+ (UIImage *)generateQRCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    
    UIImage *resized = nil;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef contextCurrent = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextCurrent, kCGInterpolationNone);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return resized;
}

// 生成条形码
+ (UIImage *)generateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setDefaults];
    
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@(5.00) forKey:@"inputQuietSpace"];
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
  
    UIImage *resized = nil;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef contextCurrent = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextCurrent, kCGInterpolationNone);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);

    return resized;
}

- (NSArray *)recognitionQRCodeFromImage {
    
    // 把图片缩放到硬件的分辨率
    CGSize scaleSize = [[UIScreen mainScreen] currentMode].size;
    UIImage *imageScale = [self resizedImageByMagick:[NSString stringWithFormat:@"%ldx%ld",(long)scaleSize.width,(long)scaleSize.height]];
    CIImage *ciImage = [[CIImage alloc] initWithImage:imageScale];
    
    //CIImage *ciImage = [[CIImage alloc] initWithImage:self];
    //创建探测器
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                  context:[CIContext contextWithOptions:nil]
                                                  options:@{CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorMinFeatureSize:@1.0}];
        NSArray<CIFeature*> *features = [detector featuresInImage:ciImage];
        
        //取出探测到的数据
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (CIQRCodeFeature *result in features) {
            if ([result.type isEqualToString:CIFeatureTypeQRCode]) {
                [results addObject:result.messageString];
            }
        }
        
        return results;
    }
    
    
    return nil;
}


@end
