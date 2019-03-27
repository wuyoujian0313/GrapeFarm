//
//  CaptchaControl.h
//  CommonProject
//
//  Created by wuyoujian on 16/7/23.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import <UIKit/UIKit.h>

// 验证码
@interface CaptchaControl : UIControl

@property (nonatomic, strong) UIColor               *textNormalColor;
@property (nonatomic, strong) UIColor               *textDisabledColor;
@property (nonatomic, strong) UIFont                *textFont;
@property (nonatomic, copy) NSString                *defaultText;

// 默认是60秒
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame interval:(NSUInteger)interval;

// 一般请在CaptchaControl的点击事件里，调用start启动倒计时
- (void)start;

@end
