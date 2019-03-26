//
//  ForgotPasswordVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/26.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "ForgotPasswordVC.h"

@interface ForgotPasswordVC ()

@end

@implementation ForgotPasswordVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ResetPassword",nil)];
}


@end
