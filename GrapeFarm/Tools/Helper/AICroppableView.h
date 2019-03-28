//
//  AICroppableView.h
//  BaiduTong
//
//  Created by wuyj on 14-11-24.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

// 模板方式切图
@interface AICroppableView : UIView
@property(nonatomic, strong) UIColor *lineColor;
@property(nonatomic, assign) float lineWidth;

// frame是UIImageView的frame,必须要图片的比例一致；
- (instancetype)initWithFrame:(CGRect)frame;
// 清除所有的画笔
- (void)cleaningBrush;
// UIImageView的UIImage
- (UIImage *)croppingOfImage:(UIImage*)image;
@end
