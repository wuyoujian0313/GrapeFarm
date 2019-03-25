//
//  AINavigationController.m
//
//
//  Created by wuyj on 14-12-27.
//  Copyright (c) 2014年 伍友健. All rights reserved.
//

#import "AINavigationController.h"

@implementation AINavigationController

- (void)dealloc
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle style = [self.topViewController preferredStatusBarStyle];
    return style;
}

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

-(BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController.presentedViewController) {
        return self.topViewController.presentedViewController.supportedInterfaceOrientations;
    }
    return self.topViewController.supportedInterfaceOrientations;
}


@end
