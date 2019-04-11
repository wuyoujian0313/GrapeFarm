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
@property (nonatomic, strong) UIViewController              *currentController;
@property (nonatomic, assign) UIViewAnimationOptions        animationOptions;
@end

@implementation MainControllerManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    _animationOptions = UIViewAnimationOptionCurveEaseIn;
    
    UIViewController *loginVC =  [self setupLoginVC];
    _currentController = loginVC;
    [self.view addSubview:_currentController.view];
    [self addChildViewController:_currentController];
   
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return _currentController;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return _currentController;
}

- (void)switchToHomeVC {
    _animationOptions = UIViewAnimationOptionTransitionFlipFromLeft;
    [self switchToHomeVCFrom:_currentController];
}

- (void)switchToLoginVC {
    _animationOptions = UIViewAnimationOptionTransitionFlipFromRight;
    [self switchToLoginVCFrom:_currentController];
}

- (void)switchViewController:(UIViewController*)fromVC {
    __weak typeof(self) wSelf = self;
    [self.view addSubview:fromVC.view];
    [self addChildViewController:_currentController];
    [self transitionFromViewController:fromVC toViewController:_currentController duration:1.0 options:_animationOptions animations:^{
    } completion:^(BOOL finished) {
        //
        typeof(self) sSelf = wSelf;
        [fromVC removeFromParentViewController];
        [sSelf.currentController didMoveToParentViewController:sSelf];
        [sSelf.currentController setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)switchToHomeVCFrom:(UIViewController*)fromVC {
    UIViewController *homeVC = [self setupHomeController];
    _currentController = homeVC;
    [self performSelector:@selector(switchViewController:) withObject:fromVC afterDelay:0.1];
}

- (void)switchToLoginVCFrom:(UIViewController*)fromVC {
    UIViewController *loginVC =  [self setupLoginVC];
    _currentController = loginVC;
    [self performSelector:@selector(switchViewController:) withObject:fromVC afterDelay:0.5];
}

- (UIViewController *)setupLoginVC {
    LoginVC *controller = [[LoginVC alloc] init];
    AINavigationController *nav = [[AINavigationController alloc] initWithRootViewController:controller];
    return nav;
}

- (UIViewController *)setupHomeController {
    HomeVC *controller = [[HomeVC alloc] init];
    AINavigationController *nav = [[AINavigationController alloc] initWithRootViewController:controller];
   // [self addChildViewController:nav];
    return nav;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
