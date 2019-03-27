//
//  AILoadingView.h
//  AIBase
//
//  Created by Wu YouJian on 2018/7/25.
//  Copyright © 2018年 Asiainfo. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface AILoadingView : UIView

//最大的loading时间，自动关闭，防止一直禁用用户的操作,默认值：90秒
+ (void)setLoadMaxTimeout:(CGFloat)time;
+ (void)show:(NSString*)status;
+ (void)dismiss;


@end
