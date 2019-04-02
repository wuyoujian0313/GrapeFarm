//
//  LoginBean.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/26.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "LoginBean.h"

@implementation LoginBean

-(void)setToken:(NSString *)token {
    _token = token;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_token forKey:kLoginTokenUserdefaultKey];
    [userDefaults synchronize];
}

@end
