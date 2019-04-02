//
//  ColorSegment?VC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/29.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "ColorSegmentVC.h"
#import "DeviceInfo.h"
#import "ModelIdentificationVC.h"

@interface ColorSegmentVC ()
@property(nonatomic,strong)UISegmentedControl *segmentCtl;
@end

@implementation ColorSegmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ColorSegment",nil)];
    [self layoutSegmentControl];
    [self layoutNextView];
}

- (void)layoutSegmentControl {
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"分割一",@"分割二",@"分割三",nil];
    _segmentCtl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentCtl.frame = CGRectMake(11,15 + [DeviceInfo navigationBarHeight],self.view.frame.size.width - 22,30);
    _segmentCtl.selectedSegmentIndex = 0;
    _segmentCtl.tintColor = [UIColor blackColor];
    [self.view addSubview:_segmentCtl];
}

- (void)layoutNextView {
    NSInteger buttonHeight = 45;
    NSInteger xfooter = 30 + buttonHeight;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kButtonTapColor]] forState:UIControlStateHighlighted];
    [nextBtn.layer setBorderColor:[UIColor colorWithHex:kBoundaryColor].CGColor];
    [nextBtn.layer setBorderWidth:kLineHeight1px];
    [nextBtn.layer setCornerRadius:kButtonCornerRadius];
    [nextBtn setClipsToBounds:YES];
    [nextBtn setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [nextBtn setFrame:CGRectMake(11, self.view.frame.size.height - xfooter, self.view.frame.size.width - 22, buttonHeight)];
    [nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)nextAction:(UIButton *)sender {
    ModelIdentificationVC *vc = [[ModelIdentificationVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
