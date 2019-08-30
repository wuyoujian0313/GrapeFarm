//
//  AIRangeSliderView.h
//  AIRangeSliderView
//
//  Created by wuyoujian on 2019/5/15.
//  Copyright © 2019年 wuyoujian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AIRangeSliderViewDelegate <NSObject>
@optional
- (void)sliderValueDidChangedOfLeft:(NSInteger)left right:(NSInteger)right;
- (void)sliderValueChangingOfLeft:(NSInteger)left right:(NSInteger)right;
@end

@interface AIRangeSliderView : UIView
@property (nonatomic,weak)id<AIRangeSliderViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<AIRangeSliderViewDelegate>)delegate;
//步长
@property(nonatomic,assign) NSInteger stepper;
//最小值
@property(nonatomic,assign) NSInteger minValue;
//最大值
@property(nonatomic,assign) NSInteger maxValue;
//左游标值
@property(nonatomic,assign) NSInteger leftValue;
//右游标值
@property(nonatomic,assign) NSInteger rightValue;
//标线默认颜色
@property(nonatomic,strong) UIColor* lineColor;
//标线高亮颜色
@property(nonatomic,strong) UIColor* highlightLineColor;
//游标线的颜色
@property(nonatomic,strong) UIColor *vernierLineColor;
@end

