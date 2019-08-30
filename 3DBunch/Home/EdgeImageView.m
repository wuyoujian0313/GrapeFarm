//
//  EdgeImageView.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/29.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "EdgeImageView.h"
#import "AICircle.h"


@interface EdgeView : UIView
@property(nonatomic,strong)NSArray *circles;
@property(nonatomic,strong)UIColor *penColor;
@end

@implementation EdgeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
    }
    return self;
}

- (void)setCircles:(NSArray *)circles {
    _circles = circles;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code

    // 1.获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx,rect);
    
    if (_penColor != nil) {
        [_penColor set];
    } else {
        [[UIColor colorWithHex:0xF3704B] set];
    }
    
    for (int i = 0; i < [_circles count]; i++) {
        AICircle *circle = _circles[i];
        CGRect rect = CGRectMake([circle.x floatValue] - [circle.r floatValue], [circle.y floatValue] - [circle.r integerValue], 2*[circle.r integerValue], 2*[circle.r integerValue]);
        // 2.画圆
        CGContextAddEllipseInRect(ctx, rect);
    }
    
    
    CGContextSetLineWidth(ctx, 1);
    // 3.显示所绘制的东西
    CGContextStrokePath(ctx);
}

- (void)clear {
    if (_circles != nil && [_circles count] > 0) {
        [self setCircles:nil];
    }
}

@end

@interface EdgeImageView ()
@property(nonatomic,strong)EdgeView *edgeView;
@end

@implementation EdgeImageView


- (void)setCircles:(NSArray *)circles {
    CGFloat w = self.image.size.width;
    CGFloat w1 = self.frame.size.width;
    CGFloat scale = w1/w;
    for (int i = 0; i < [circles count]; i ++) {
        AICircle *c = circles[i];
        c.x = [NSNumber numberWithFloat:[c.x floatValue] * scale];
        c.y = [NSNumber numberWithFloat:[c.y floatValue] * scale];
        c.r = [NSNumber numberWithFloat:[c.r integerValue] * scale];
    }
    [_edgeView setFrame:self.bounds];
    [_edgeView setCircles:circles];
}

- (void)setPenColor:(UIColor *)color {
    [_edgeView setPenColor:color];
}

- (void)layoutSubviews {
    [_edgeView setFrame:self.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        self.edgeView = [[EdgeView alloc] initWithFrame:self.bounds];
        [self addSubview:_edgeView];
    }
    return self;
}

- (void)clear {
    [_edgeView clear];
}




@end
