//
//  SaveSimpleDataManager.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/3.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "SaveSimpleDataManager.h"

@implementation SaveSimpleDataManager

- (void)setObject:(id)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

- (id)objectForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

@end
