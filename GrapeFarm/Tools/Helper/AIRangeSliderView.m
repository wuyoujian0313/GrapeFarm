//
//  AIRangeSliderView.h
//  AIRangeSliderView
//
//  Created by wuyoujian on 2019/5/15.
//  Copyright © 2019年 wuyoujian. All rights reserved.
//

#import "AIRangeSliderView.h"

@interface AIRangeSliderView()

@property (nonatomic,strong) UIView* leftCursorButton;
@property (nonatomic,strong) UIView* rightCursorButton;
@property (nonatomic,strong) UIView* backgroundLine;
@property (nonatomic,strong) UIView* leftLine;
@property (nonatomic,strong) UIView* rightLine;
@property (nonatomic,strong) UIView* leftVernierLine;
@property (nonatomic,strong) UIView* rightVernierLine;

@property (nonatomic,assign) CGFloat itemRadius;
@property (nonatomic,assign) CGFloat itemSize;
// 线高
@property (nonatomic,assign) CGFloat lineHeight;
@end

@implementation AIRangeSliderView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<AIRangeSliderViewDelegate>)delegate {
    _delegate = delegate;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        _itemSize = 30;
        _lineHeight = 2;
        _stepper = 1;
        _maxValue = 100.0;
        _minValue = 0.0;
        _leftValue = _minValue;
        _rightValue = _maxValue;
        _lineColor = [UIColor lightGrayColor] ;
        _highlightLineColor = [UIColor blackColor];
        // 底线
        CGFloat lineY = CGRectGetHeight(self.bounds) - (self.itemRadius-_lineHeight/2);
        self.backgroundLine = [[UIView alloc] initWithFrame:CGRectMake(self.itemRadius, lineY , CGRectGetWidth(self.bounds)-_itemSize, _lineHeight)];
        _backgroundLine.backgroundColor = _highlightLineColor;
        [self addSubview:_backgroundLine];
        // 左线
        self.leftLine = [[UIView alloc] initWithFrame:CGRectMake(self.itemRadius, lineY, 0, _lineHeight)];
        [self addSubview:_leftLine];
        _leftLine.backgroundColor = _lineColor;
        CGFloat scale = [UIScreen mainScreen].scale;
        
        // 左游标线
        self.leftVernierLine = [[UIView alloc] initWithFrame:CGRectMake(_itemSize-scale, 0, scale, lineY)];
        _leftVernierLine.backgroundColor = [UIColor blackColor];
        [self addSubview:_leftVernierLine];
        
        // 左游标按钮
        self.leftCursorButton = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - _itemSize, _itemSize, _itemSize)];
        [self addSubview:_leftCursorButton];
        [_leftCursorButton.layer setCornerRadius:_itemSize/2];
        [_leftCursorButton.layer setBorderColor:[UIColor blackColor].CGColor];
        [_leftCursorButton.layer setBorderWidth:scale];
        [_leftCursorButton setBackgroundColor:[UIColor whiteColor]];
        
        UIPanGestureRecognizer* padLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(eventPan:)];
        [_leftCursorButton addGestureRecognizer:padLeft];
        
        // 右线
        self.rightLine = [[UIView alloc] initWithFrame:CGRectMake(0, lineY, 0, _lineHeight)];
        _rightLine.backgroundColor = _lineColor;
        [self addSubview:_rightLine];
        // 右游标线
        self.rightVernierLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-_itemSize, 0, scale, lineY)];
        _rightVernierLine.backgroundColor = [UIColor blackColor];
        [self addSubview:_rightVernierLine];
        
        // 右游标按钮
        self.rightCursorButton = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-_itemSize, CGRectGetHeight(self.bounds) - _itemSize, _itemSize, _itemSize)];
        [self addSubview:_rightCursorButton];
        [_rightCursorButton.layer setCornerRadius:_itemSize/2];
        [_rightCursorButton.layer setBorderColor:[UIColor blackColor].CGColor];
        [_rightCursorButton.layer setBorderWidth:scale];
        [_rightCursorButton setBackgroundColor:[UIColor whiteColor]];
        
        UIPanGestureRecognizer* padRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(eventPan:)];
        [_rightCursorButton addGestureRecognizer:padRight];
    }
    return self;
}

- (void)setStepper:(NSInteger)stepper {
    if(stepper == 0.0) return;
    _stepper = stepper;
}

- (void)setVernierPositionOfValue:(NSInteger)value vernierButton:(UIView*)button line:(UIView *)line vernierLine:(UIView *)vernierLine isLeft:(BOOL)isLeft  {
    NSInteger totalOfCalibration = (_maxValue - _minValue)/_stepper;
    CGFloat widthOfCalibration = (self.frame.size.width-_itemSize*2)/totalOfCalibration;
    //按钮
    CGRect framOfButton= button.frame;
    framOfButton.origin.x = widthOfCalibration*value  + (isLeft?0:_itemSize);
    button.frame = framOfButton;
    //线
    CGRect framOfLine = line.frame;
    framOfLine.origin.x = self.itemRadius + (isLeft?0:framOfButton.origin.x);
    framOfLine.size.width = isLeft?widthOfCalibration*value:self.frame.size.width - widthOfCalibration*value - _itemSize*2;
    line.frame = framOfLine;
    
    //游标线
    CGRect frameOfLeftVernierLine = vernierLine.frame;
    
    frameOfLeftVernierLine.origin.x = isLeft? button.frame.origin.x + _itemSize - vernierLine.frame.size.width: button.frame.origin.x;
    vernierLine.frame = frameOfLeftVernierLine;
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(sliderValueDidChangedOfLeft:right:)]){
        [_delegate sliderValueDidChangedOfLeft:_leftValue right:_rightValue];
    }
}

- (void)setLeftValue:(NSInteger)leftValue {
    leftValue = leftValue<_minValue?_minValue:leftValue;
    _leftValue = leftValue;
    leftValue -= _minValue;
    //占用多少个步长
    leftValue /= _stepper;
    
    [self setVernierPositionOfValue:leftValue vernierButton:_leftCursorButton line:_leftLine vernierLine:_leftVernierLine isLeft:YES];
}

- (void)setRightValue:(NSInteger)rightValue {
    rightValue = rightValue>self.maxValue?self.maxValue:rightValue;
    _rightValue = rightValue;
    rightValue -= _minValue;
    rightValue /= _stepper;
    
    [self setVernierPositionOfValue:rightValue vernierButton:_rightCursorButton line:_rightLine vernierLine:_rightVernierLine  isLeft:NO];
}

- (void)setLineColor:(UIColor *)lineColor {
    _leftLine.backgroundColor = lineColor;
    _rightLine.backgroundColor = lineColor;
}

- (void)setHighlightLineColor:(UIColor *)highlightLineColor {
    _backgroundLine.backgroundColor = highlightLineColor;
}


-(void)setVernierLineColor:(UIColor *)vernierLineColor {
    _leftVernierLine.backgroundColor = vernierLineColor;
    _rightVernierLine.backgroundColor = vernierLineColor;
}

- (CGFloat)itemRadius {
    return self.itemSize/2;
}

#pragma mark - 触摸事件
- (void)eventPan:(UIPanGestureRecognizer*)pan {
    CGPoint point = [pan translationInView:self];
    static CGPoint center;
    if (pan.state == UIGestureRecognizerStateBegan) {
        center = pan.view.center;
        // 阻止双手操作
        _leftCursorButton.userInteractionEnabled = (pan.view == _leftCursorButton);
        _rightCursorButton.userInteractionEnabled = (pan.view == _rightCursorButton);
    }
    
    // 随着触摸移动游标滑块
    pan.view.center = CGPointMake(center.x + point.x, pan.view.center.y);
    
    //刻度总份数
    NSInteger totalOfCalibration = (_maxValue - _minValue)/_stepper;
    //无效的坐标系长度
    CGFloat ineffectiveLength = _itemSize*2;
    //一个刻度的宽
    CGFloat widthOfCalibration = (self.frame.size.width -ineffectiveLength)/totalOfCalibration;
    if (pan.state == UIGestureRecognizerStateEnded) {
        _leftCursorButton.userInteractionEnabled = YES;
        _rightCursorButton.userInteractionEnabled = YES;
        // 取整数刻度处理
        if(pan.view == _leftCursorButton) {
            CGFloat countOfCalibration = round((pan.view.center.x-self.itemRadius)/widthOfCalibration);
            pan.view.center = CGPointMake(countOfCalibration*widthOfCalibration+ineffectiveLength/4, pan.view.center.y);
        } else {
            CGFloat countOfCalibration = round((self.frame.size.width - pan.view.center.x-self.itemRadius)/widthOfCalibration);
            pan.view.center = CGPointMake(self.frame.size.width - countOfCalibration*widthOfCalibration-ineffectiveLength/4, pan.view.center.y);
        }
        
        if(_delegate != nil && [_delegate respondsToSelector:@selector(sliderValueDidChangedOfLeft:right:)]){
            [_delegate sliderValueDidChangedOfLeft:_leftValue right:_rightValue];
        }
    }
    
    if(pan.view == _leftCursorButton) {
        if (CGRectGetMaxX(_leftCursorButton.frame) > CGRectGetMinX(_rightCursorButton.frame)) {
            // 不能超过右游标的边缘
            CGRect frame = _leftCursorButton.frame;
            frame.origin.x = CGRectGetMinX(_rightCursorButton.frame)-_itemSize;
            _leftCursorButton.frame = frame;
        } else {
            if (pan.view.center.x < self.itemRadius) {
                // 只能滑到左边缘
                CGPoint center = _leftCursorButton.center;
                center.x = self.itemRadius;
                _leftCursorButton.center = center;
            }
        }
        
        CGRect frameOfLeftVernierLine = _leftVernierLine.frame;
        frameOfLeftVernierLine.origin.x = _leftCursorButton.frame.origin.x + _itemSize - _leftVernierLine.frame.size.width;
        _leftVernierLine.frame = frameOfLeftVernierLine;
        CGRect frameOfLine = _leftLine.frame;
        frameOfLine.size.width = _leftCursorButton.center.x - self.itemRadius;
        _leftLine.frame = frameOfLine;
        
        _leftValue = round((_leftCursorButton.center.x-self.itemRadius)/widthOfCalibration)*_stepper+_minValue;
    } else {
        if (CGRectGetMinX(_rightCursorButton.frame) < CGRectGetMaxX(_leftCursorButton.frame)) {
            //不能超过左游标的边缘
            CGRect frame = _rightCursorButton.frame;
            frame.origin.x = CGRectGetMaxX(_leftCursorButton.frame);
            _rightCursorButton.frame = frame;
        }else{
            if (pan.view.center.x > CGRectGetWidth(self.bounds)-self.itemRadius) {
                // 只能滑到右边缘
                CGPoint center = _rightCursorButton.center;
                center.x = CGRectGetWidth(self.bounds)-self.itemRadius;
                _rightCursorButton.center = center;
            }
        }
        
        CGRect frameOfRightVernierLine = _rightVernierLine.frame;
        frameOfRightVernierLine.origin.x = _rightCursorButton.frame.origin.x;
        _rightVernierLine.frame = frameOfRightVernierLine;
        
        CGRect frameOfLine = _rightLine.frame;
        frameOfLine.size.width = CGRectGetWidth(self.bounds) - _rightCursorButton.center.x - self.itemRadius;
        frameOfLine.origin.x = _rightCursorButton.center.x;
        _rightLine.frame = frameOfLine;
        
        _rightValue = self.maxValue - round((self.frame.size.width-_rightCursorButton.center.x-self.itemRadius)/widthOfCalibration)*self.stepper;
    }
    
    // 滑动中回调
    if(_delegate != nil && [_delegate respondsToSelector:@selector(sliderValueChangingOfLeft:right:)]){
        [_delegate sliderValueChangingOfLeft:_leftValue right:_rightValue];
    }
    
}

@end

