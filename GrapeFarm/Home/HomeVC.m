//
//  HomeVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/25.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "HomeVC.h"
#import "SettingsVC.h"
#import "ColorSegmentVC.h"
#import "DeviceInfo.h"
#import "LineView.h"
#import "AICroppableView.h"
#import "UIView+SizeUtility.h"

@interface HomeVC ()
@property (nonatomic,strong)UIImageView *imageView;
@end

@implementation HomeVC

-(void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"AppName",nil)];
    [self layoutNavView];
    [self layoutImageAreaView];
    [self layoutToolsView];
}

- (void)layoutImageAreaView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10 + [DeviceInfo navigationBarHeight], self.view.frame.size.width, 30)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor colorWithHex:kTextGrayColor]];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label setText:NSLocalizedString(@"SelectImageArea", nil)];
    [self.view addSubview:label];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, label.bottom + 10, 0, 0)];
    [self.view addSubview:_imageView];
}

- (void)layoutNavView {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(toSettingPage)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)layoutToolsView {
    NSInteger buttonWidth = 60;
    NSInteger xfooter = 30 + buttonWidth;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - xfooter, self.view.frame.size.width, buttonWidth)];
    [self.view addSubview:toolView];
    
    NSInteger space = (self.view.frame.size.width - 4*buttonWidth)/5.0;
    for (NSInteger i = 0; i < 4; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(space*(i+1) + i*buttonWidth, 0, buttonWidth, buttonWidth)];
        [button setTag:i + 10];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld",(long)i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld-on",(long)i]] forState:UIControlStateHighlighted];
        [button.layer setBorderColor:[UIColor colorWithHex:kTextGrayColor].CGColor];
        [button.layer setBorderWidth:kLineHeight1px];
        [button.layer setCornerRadius:buttonWidth/2.0];
        [button setClipsToBounds:YES];
        [button addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:button];
    }
}

- (void)toolAction:(UIButton *)sender {
    NSInteger type = sender.tag - 10;
    if (type == 0) {
        //拍照
    } else if (type == 1) {
        //相册
    } else if (type == 2) {
        //重置
    } else if (type == 3) {
        //确定
        ColorSegmentVC *vc = [[ColorSegmentVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)toSettingPage {
    SettingsVC *vc = [[SettingsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
