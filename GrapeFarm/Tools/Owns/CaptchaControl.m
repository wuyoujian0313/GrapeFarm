//
//  CaptchaControl.m
//  CommonProject
//
//  Created by wuyoujian on 16/7/23.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import "CaptchaControl.h"

@interface CaptchaControl ()

@property (nonatomic, strong) UILabel               *timeLabel;
@property (nonatomic, assign) NSInteger             lessTime;			// 剩余时间的总秒数
@property (nonatomic, assign) NSInteger             interval;			// 总秒数
@property (nonatomic, assign) CFRunLoopRef          runLoop;			// 消息循环
@property (nonatomic, assign) CFRunLoopTimerRef     timer;				// 消息循环定时器

void CaptchaControlCFTimerCallback(CFRunLoopTimerRef timer, void *info);

@end

@implementation CaptchaControl

- (void)dealloc {
    if (_runLoop != nil && _timer != nil) {
        CFRunLoopTimerInvalidate(_timer);
        CFRunLoopRemoveTimer(_runLoop, _timer, kCFRunLoopCommonModes);
        [self setRunLoop:nil];
        [self setTimer:nil];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame interval:60];
}

- (instancetype)initWithFrame:(CGRect)frame interval:(NSUInteger)interval {
    
    self = [super initWithFrame:frame];
    if (self) {
        //
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.timeLabel = timeLabel;
        
        [timeLabel setFont:[UIFont systemFontOfSize:13]];
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:timeLabel];
        
        self.interval = interval;
        self.textDisabledColor = [UIColor grayColor];
        self.textNormalColor = [UIColor blackColor];
        
        self.defaultText = NSLocalizedString(@"V-code", nil);
    }
    
    return self;
}

// 更新剩余时间
- (void)updateLessTime {
    NSString *sendString = NSLocalizedString(@"Resend", nil);
    if(_lessTime > 0) {
        NSString *lessTimeTmp = [[NSString alloc] initWithFormat:@"%@(%lu)",sendString,(unsigned long)_lessTime];
        [self setTextDisabledColor:_textDisabledColor];
        [_timeLabel setText:lessTimeTmp];
        [self setEnabled:NO];
    } else {
        NSString *lessTimeTmp = [[NSString alloc] initWithFormat:@"%@",sendString];
        [self setTextNormalColor:_textNormalColor];
        [_timeLabel setText:lessTimeTmp];
        [self setEnabled:YES];
    }
}

// 启动消息循环定时器
- (void)start {
    _lessTime = _interval;
    // 创建消息循环定时器
    _runLoop = CFRunLoopGetCurrent();
    CFRunLoopTimerContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 1, 1.0, 0, 0,
                                  &CaptchaControlCFTimerCallback, &context);
    
    CFRunLoopAddTimer(_runLoop, _timer, kCFRunLoopCommonModes);
}

// 时钟回调函数
void CaptchaControlCFTimerCallback(CFRunLoopTimerRef timer, void *info) {
    // 剩余时间减1
    CaptchaControl *selfObj = (__bridge id)info;
    
    // 时间秒数减1
    [selfObj setLessTime:[selfObj lessTime] - 1];
    
    // 更新倒计时时间
    [selfObj updateLessTime];
    
    if ([selfObj lessTime] <= 0) {
        CFRunLoopRemoveTimer([selfObj runLoop], [selfObj timer], kCFRunLoopCommonModes);
        [selfObj setRunLoop:nil];
        [selfObj setTimer:nil];
    }
}

- (void)setTextNormalColor:(UIColor *)textColor {
    _textNormalColor = textColor;
    [_timeLabel setTextColor:textColor];
}

- (void)setTextDisabledColor:(UIColor *)textColor {
    _textDisabledColor = textColor;
    [_timeLabel setTextColor:textColor];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    [_timeLabel setFont:textFont];
}

- (void)setDefaultText:(NSString *)defaultText {
    _defaultText = defaultText;
    [_timeLabel setText:defaultText];
}

// =====================================================================
#pragma mark Touch Tracking
// ======================================================================

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

// 交互统计
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [super sendAction:action to:target forEvent:event];
}

@end
