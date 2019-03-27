//
//  BaseVC.h
//
//
//  Created by wuyj on 14-12-8.
//  Copyright (c) 2014年 伍友健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController

- (void)setNavTitle:(NSString*)title;
- (void)setNavTitle:(NSString*)title titleColor:(UIColor *)color;

- (UIBarButtonItem*)configBackButton;


- (UIButton*)configRightBarButtonWithImage:(UIImage*)image selectImage:(UIImage*)selectIamge target:(id)target selector:(SEL)selector frame:(CGRect)frame;
- (UIButton*)configLeftBarButtonWithImage:(UIImage*)image selectImage:(UIImage*)selectIamge target:(id)target selector:(SEL)selector;

- (UIBarButtonItem*)configBarButtonWithTitle:(NSString*)title titleTextAttributes:(NSDictionary*)attrDic target:(id)target selector:(SEL)selector;

- (UIBarButtonItem*)configBarButtonWithTitle:(NSString*)title target:(id)target selector:(SEL)selector;

- (void)configRightBarButtonWithCustomView:(UIView*)aView;
- (void)configLeftBarButtonWithCustomView:(UIView*)aView;
- (void)configTitleWithImage:(NSString*)imagename;

- (void)popBack;

#pragma mark - 子类是实现
- (void)regieditKeyboardNotification;
- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardDidShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;
- (void)didEnterBackgroundNotification:(NSNotification *)note;

@end
