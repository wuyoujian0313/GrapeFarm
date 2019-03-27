//
//  AILoadingView.m
//  AIBase
//
//  Created by Wu YouJian on 2018/7/25.
//  Copyright © 2018年 Asiainfo. All rights reserved.
//


#import "AILoadingView.h"
#import "NSString+Utility.h"
#import "UIView+SizeUtility.h"


#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width

static  const CGFloat kLoadingViewTag = 313003;
static  const CGFloat kLoadingViewMaxWidth = 300;
static  const CGFloat kActivityIndicatorViewWidth = 22;

//默认最大的loading时间，自动关闭，防止一直禁用用户的操作
static CGFloat kLoadingViewMaxTimeout = 90.0f;

@interface AILoadingView()

@property(nonatomic, strong) UIView                         *backgroundView;
@property(nonatomic, strong) UIActivityIndicatorView        *indicatorView;
@property(nonatomic, strong) UILabel                        *textLabel;

@end

@implementation AILoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UIView *markView = [[UIView alloc] initWithFrame:self.bounds];
        [markView setUserInteractionEnabled:NO];
        [markView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:markView];
        
        // Initialization code
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
        [backgroundView setClipsToBounds:YES];
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [backgroundView addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [textLabel setNumberOfLines:0];
        [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [backgroundView addSubview:textLabel];
        
        self.textLabel = textLabel;
    }
    return self;
}

- (void)dismiss {
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(self)Sself = wSelf;
        [UIView animateWithDuration:0.2 animations:^{
            Sself.alpha = 0.0;
        } completion:^(BOOL finished) {
            [Sself.indicatorView stopAnimating];
            [Sself removeFromSuperview];
        }];
    });
}

- (void)show:(NSString*)status {
    
    __weak typeof(self) wSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        typeof(self)Sself = wSelf;
        
        CGSize size = [status sizeWithFontCompatible:self.textLabel.font constrainedToSize:CGSizeMake(kLoadingViewMaxWidth - 30, CGFLOAT_MAX) lineBreakMode:self.textLabel.lineBreakMode];
        
        CGFloat margin = 10;
        CGFloat w = size.width + kActivityIndicatorViewWidth + margin *3;
        CGFloat tmpH = kActivityIndicatorViewWidth + margin;
        CGFloat h = MAX(size.height + 2*margin,tmpH);
        CGFloat x = (screenWidth - w )/2.0;
        CGFloat y = (screenHeight  - h)/2.0;
        
        Sself.textLabel.text = status;
        CGRect rect =  CGRectMake(x , y, w, h);
        Sself.backgroundView.frame = rect;
        Sself.indicatorView.frame = CGRectMake(margin, (h-kActivityIndicatorViewWidth)/2.0, kActivityIndicatorViewWidth, kActivityIndicatorViewWidth);
        Sself.textLabel.frame = CGRectMake(self.indicatorView.right + margin,(h - size.height)/2.0, size.width, size.height);
        
        Sself.backgroundView.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            Sself.backgroundView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [Sself.indicatorView startAnimating];
            //最大时长90秒自动关闭，防止一直禁用用户的操作
            [Sself performSelector:@selector(dismiss) withObject:nil afterDelay:kLoadingViewMaxTimeout];
        }];
    });
}

+ (void)setLoadMaxTimeout:(CGFloat)time {
    kLoadingViewMaxTimeout = time;
}

+ (void)show:(NSString*)status {
    AILoadingView *loadView = [[AILoadingView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadView];
    [loadView setTag:kLoadingViewTag];
    [loadView show:status];
}


+ (void)dismiss {
    AILoadingView *loadView = (AILoadingView *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:kLoadingViewTag];
    if(loadView != nil) {
        [loadView dismiss];
    }
}

@end
