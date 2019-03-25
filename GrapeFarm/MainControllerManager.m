//
//  MainControllerManager.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/25.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "MainControllerManager.h"
#import "AINavigationController.h"
#import "LoginVC.h"
#import "HomeVC.h"
#import "UIColor+Utility.h"

@interface MainControllerManager ()
@property (nonatomic, strong) UIViewController              *rootVC;
@property (nonatomic, strong) UIViewController              *currentController;
@end

@implementation MainControllerManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupRootVC];
    [self switchToLoginVCFrom:_rootVC];
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return _currentController;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return _currentController;
}

- (void)switchToHomeVC {
    [self switchToHomeVCFrom:_currentController];
}

- (void)switchToLoginVC {
    [self switchToLoginVCFrom:_currentController];
}

// 创建一个空白的rootVC用于页面切换
- (void)setupRootVC {
    UIViewController *rootVC = [[UIViewController alloc] init];
    self.rootVC = rootVC;
    [self addChildViewController:_rootVC];
    [_rootVC didMoveToParentViewController:self];
}


- (void)switchToHomeVCFrom:(UIViewController*)fromVC {
    
    __weak typeof(self) wSelf = self;
    UIViewController *homeVC = [self setupHomeController];
    [self transitionFromViewController:fromVC toViewController:homeVC duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        //
        typeof(self) sSelf = wSelf;
        [fromVC removeFromParentViewController];
        sSelf.currentController = homeVC;
        
        [sSelf.currentController didMoveToParentViewController:sSelf];
        [sSelf.currentController setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        //
        
    }];
}

- (void)switchToLoginVCFrom:(UIViewController*)fromVC {
    UIViewController *loginVC =  [self setupLoginVC];
    
    __weak typeof(self) wSelf = self;
    [self transitionFromViewController:fromVC toViewController:loginVC duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        //
        typeof(self) sSelf = wSelf;
        [fromVC removeFromParentViewController];
        sSelf.currentController = loginVC;
        [sSelf.currentController didMoveToParentViewController:sSelf];
        [sSelf.currentController setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        //
        
    }];
}

- (UIViewController *)setupLoginVC {
    LoginVC *controller = [[LoginVC alloc] init];
    AINavigationController *nav = [[AINavigationController alloc] initWithRootViewController:controller];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    return nav;
}

- (UIViewController *)setupHomeController {
    HomeVC *controller = [[HomeVC alloc] init];
    AINavigationController *nav = [[AINavigationController alloc] initWithRootViewController:controller];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    return nav;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
