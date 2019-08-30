//
//  FadePromptView.h
//
//  Created by wuyj on 5/27/13.
//  Copyright (c) 2013 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^finishPrompt)(void);

static  const CGFloat kFadePromptViewMaxWidth = 300;

@interface FadePromptView : UIView

+(void)showPromptStatus:(NSString*)status duration:(NSTimeInterval)seconds finishBlock:(finishPrompt)finish;
+(void)showPromptStatus:(NSString*)status duration:(NSTimeInterval)seconds positionY:(CGFloat)y finishBlock:(finishPrompt)finish;

@end


