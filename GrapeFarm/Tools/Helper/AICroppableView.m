//
//  AICroppableView.m
//  BaiduTong
//
//  Created by wuyj on 14-11-24.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "AICroppableView.h"
#import "UIBezierPath+Points.h"

@interface AICroppableView ()
@property(nonatomic, strong) UIBezierPath *croppingPath;
@property(assign) CGSize size;
@end

@implementation AICroppableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 默认画笔参数
        _lineWidth = 5.0f;
        _lineColor = [UIColor whiteColor];
        _size = frame.size;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        _croppingPath = [[UIBezierPath alloc] init];
        [_croppingPath setLineWidth:_lineWidth];
        
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _size = frame.size;
}

- (void)appendPath:(UIBezierPath *)path {
    [_croppingPath appendPath:path];
}

- (void)cleaningBrush {
    [_croppingPath removeAllPoints];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [_lineColor setStroke];
    [_croppingPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
}

- (BOOL)canCropping {
    if ([_croppingPath points] ==nil || [[_croppingPath points] count] == 0) {
        // 未剪切
        return NO;
    }
    
    return YES;
}

- (UIImage *)orientationCorrectedImage:(UIImage *)image {
    UIImage * resultImage = nil;
    resultImage = image;
    UIImageOrientation imageOrientation = image.imageOrientation;
    if(imageOrientation != UIImageOrientationUp){
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return resultImage;
}

- (UIImage *)croppingOfImage:(UIImage*)image backgroudColor:(UIColor *)color {
    if ([_croppingPath points] ==nil || [[_croppingPath points] count] == 0) {
        // 未剪切
        return [self orientationCorrectedImage:image];
    }
    NSArray *points = [_croppingPath points];
    CGRect rect = CGRectZero;
    rect.size = image.size;
    
    UIBezierPath *aPath;
    
    // 画一个蒙版
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 1.0);
    {
        // 背景颜色
        [[UIColor blackColor] setFill];
        UIRectFill(rect);
        [[UIColor whiteColor] setFill];
        
        aPath = [UIBezierPath bezierPath];
        
        CGPoint p1 = [self convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromViewRect:_size toImageRect:image.size];
        [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
        
        for (uint i = 1; i<points.count; i++) {
            CGPoint p = [self convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromViewRect:_size toImageRect:image.size];
            [aPath addLineToPoint:CGPointMake(p.x, p.y)];
        }
        [aPath closePath];
        [aPath fill];
    }
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 以蒙版图片进行剪切图片
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        [image drawAtPoint:CGPointZero];
    }
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (color != nil) {
        //1.开启上下文
        UIGraphicsBeginImageContextWithOptions(maskedImage.size, NO, 1.0);
        //2.绘制背景图片
        UIImage *bgImage = [UIImage imageFromColor:color];
        [bgImage drawInRect:CGRectMake(0, 0, maskedImage.size.width, maskedImage.size.height)];
        [maskedImage drawInRect:CGRectMake(0, 0, maskedImage.size.width, maskedImage.size.height)];
        //3.从上下文中获取新图片
        maskedImage = UIGraphicsGetImageFromCurrentImageContext();
        //4.关闭图形上下文
        UIGraphicsEndImageContext();
    }

//    CGRect croppedRect = aPath.bounds;
////    // 注意图片坐标是笛卡尔坐标系,y轴是向上的
//    croppedRect.origin.y = rect.size.height - CGRectGetMaxY(aPath.bounds);
//    croppedRect.origin.x = croppedRect.origin.x*2;
//    croppedRect.origin.y = croppedRect.origin.y*2;
//    croppedRect.size.width = croppedRect.size.width*2;
//    croppedRect.size.height = croppedRect.size.height*2;
//    CGImageRef imageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, croppedRect);
//    maskedImage = [UIImage imageWithCGImage:imageRef];
    
    return maskedImage;
}

// 计算在图上的坐标，
- (CGPoint)convertCGPoint:(CGPoint)point fromViewRect:(CGSize)rect1 toImageRect:(CGSize)rect2 {
    // 注意图片坐标是笛卡尔坐标系,y轴是向上的
    point.y = rect1.height - point.y;
    CGPoint result = CGPointMake((point.x*rect2.width)/rect1.width, (point.y*rect2.height)/rect1.height);
    return result;
}

#pragma mark - Touch Methods -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [_croppingPath moveToPoint:[mytouch locationInView:self]];
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [_croppingPath addLineToPoint:[mytouch locationInView:self]];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{}

@end
