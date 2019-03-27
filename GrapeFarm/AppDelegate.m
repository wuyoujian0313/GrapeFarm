//
//  AppDelegate.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/25.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseVC.h"
#import "AINavigationController.h"
#import "MainControllerManager.h"
#import "UIColor+Utility.h"



@interface AppDelegate ()
@property (nonatomic, strong) AINavigationController     *mainNav;
@property (nonatomic, strong) MainControllerManager      *mainVC;
@end

@implementation AppDelegate

+ (AppDelegate*)shareMyApplication {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)switchToHomePage {
    [_mainVC switchToHomeVC];
}
- (void)switchToLoginPage {
    [_mainVC switchToLoginVC];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainControllerManager *tempVC = [[MainControllerManager alloc] init];
    self.mainVC = tempVC;
    
    AINavigationController *tempNav = [[AINavigationController alloc] initWithRootViewController:_mainVC];
    self.mainNav = tempNav;
    [_mainNav.navigationBar setBarTintColor:[UIColor colorWithHex:0xF7F7F7]];
    _mainNav.navigationBarHidden = YES;
    
    self.window.rootViewController = _mainNav;
    [_window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
