//
//  LineView.h
//  BaiduTong
//
//  Created by wuyj on 14-11-27.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLineHeight1px (1/[[UIScreen mainScreen] scale])

@interface LineView : UIImageView


#pragma mark - 不采用draw的方式
//@property (nonatomic, assign) BOOL isDotted;		// 是否为虚线
//@property (nonatomic, assign) BOOL isVertical;		// 是否为竖线
//@property (nonatomic, strong) NSArray *arrayColor;	// 颜色Array

// 创建
//- (id)init;
//- (id)initWithFrame:(CGRect)frameInit;
//- (id)initDottedWithFrame:(CGRect)frameInit;

// 重新设置Frame
//- (void)setFrame:(CGRect)frame;


@property (nonatomic, copy) UIColor *lineColor;

@end
