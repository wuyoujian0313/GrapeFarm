//
//  HomeVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/25.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "HomeVC.h"
#import "SettingsVC.h"


#warning 测试代码
#import "Commit3DDataVC.h"

@interface HomeVC ()

@end

@implementation HomeVC

-(void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"AppName",nil)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toSettingPage)];
    self.navigationItem.rightBarButtonItem = item;

}

- (void)toSettingPage {
    
#warning 测试代码
//    SettingsVC *vc = [[SettingsVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];

    Commit3DDataVC *vc = [[Commit3DDataVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
