//
//  UIAlertController+supportedInterfaceOrientations.m
//  Portal-sx
//
//  Created by wuyoujian on 2017/7/13.
//  Copyright © 2017年 Asiainfo. All rights reserved.
//

#import "UIAlertController+Orientations.h"

@implementation UIAlertController (AIOrientations)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations; {
    return UIInterfaceOrientationMaskPortrait;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

@end
