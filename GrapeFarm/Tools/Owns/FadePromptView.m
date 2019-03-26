//
//  FadePromptView.m
//
//  Created by wuyj on 5/27/13.
//  Copyright (c) 2013 wuyj. All rights reserved.
//

#import "FadePromptView.h"
#import "NSString+Utility.h"


#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width


@interface FadePromptView()

@property(nonatomic, strong, readonly) NSTimer  *fadeOutTimer;
@property(nonatomic, strong) UILabel            *promptLabel;
@property(nonatomic, copy) finishPrompt         finishBlock;

@end


@implementation FadePromptView

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    if(_fadeOutTimer){
        //因为不是一个重复性的NSTimer所以不需要invalidate
        //[fadeOutTimer invalidate];
        _fadeOutTimer = nil;
    }
    
    if(newTimer)
        _fadeOutTimer = newTimer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
        [self setClipsToBounds:YES];
        
        UILabel* prompt = [[UILabel alloc] initWithFrame:CGRectZero];
        [prompt setBackgroundColor:[UIColor clearColor]];
        [prompt setTextColor:[UIColor whiteColor]];
        [prompt setFont:[UIFont systemFontOfSize:16]];
        [prompt setNumberOfLines:0];
        [prompt setLineBreakMode:NSLineBreakByWordWrapping];
        [self addSubview:prompt];
        
        self.promptLabel = prompt;

    }
    return self;
}


+(void)showPromptStatus:(NSString*)status duration:(NSTimeInterval)seconds finishBlock:(finishPrompt)finish {
    FadePromptView *promptView = [[FadePromptView alloc] initWithFrame:CGRectZero];
    [[[UIApplication sharedApplication] keyWindow] addSubview:promptView];
    promptView.finishBlock = [finish copy];
    [promptView show:status duration:seconds positionY:screenHeight - 100];
}

+(void)showPromptStatus:(NSString*)status duration:(NSTimeInterval)seconds positionY:(CGFloat)y  finishBlock:(finishPrompt)finish {
    FadePromptView *promptView = [[FadePromptView alloc] initWithFrame:CGRectZero];
    [[[UIApplication sharedApplication] keyWindow] addSubview:promptView];
    
    promptView.finishBlock = [finish copy];
    
    [promptView show:status duration:seconds positionY:y];
}

- (void)show:(NSString*)status duration:(NSTimeInterval)seconds positionY:(CGFloat)y {
    
    __block CGFloat yy = y;
    __weak typeof(self) wSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        typeof(self)Sself = wSelf;
        
        CGSize size = [status sizeWithFontCompatible:Sself.promptLabel.font constrainedToSize:CGSizeMake(kFadePromptViewMaxWidth - 30, CGFLOAT_MAX) lineBreakMode:Sself.promptLabel.lineBreakMode];
        
        CGFloat w = size.width + 30;
        CGFloat h = size.height + 16;
        CGFloat x = (screenWidth - w )/2.0;
        yy = yy  - h;
        
        Sself.promptLabel.text = status;
        CGRect rect =  CGRectMake(x , yy, w, h);
        Sself.frame = rect;
        Sself.promptLabel.frame = CGRectMake(15, 8, size.width, size.height);
        
        Sself.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            Sself.alpha = 1.0;

        } completion:^(BOOL finished) {
            
            [Sself dismiss:seconds];
        }];
    });
}

-(void)dismiss:(NSTimeInterval)seconds{
    self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
}

-(void)dismiss {
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            typeof(self)Sself = wSelf;
            Sself.alpha = 0.0;
        } completion:^(BOOL finished) {
            typeof(self)Sself = wSelf;
            [Sself removeFromSuperview];
            
            if (Sself.finishBlock) {
                Sself.finishBlock();
            }
        }];
        
    });
}


@end
