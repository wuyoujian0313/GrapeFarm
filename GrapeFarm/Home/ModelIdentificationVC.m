//
//  ModelIdentificationVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/2.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "ModelIdentificationVC.h"
#import "DeviceInfo.h"
#import "UIView+SizeUtility.h"
#import "D3ModelImageVC.h"


@interface ModelIdentificationVC ()
@property(nonatomic,strong)UIButton *nextBtn;
@property(nonatomic,strong)UISlider *slider1;
@property(nonatomic,strong)UISlider *slider2;
@property(nonatomic,strong)UISlider *slider3;
@end

@implementation ModelIdentificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ModelIdentification", nil)];
    [self layoutNextView];
    [self layoutParamView];
}


- (void)layoutParamView {
    NSInteger footer = 40;
    NSInteger space = 10;
    UIView *paramView = [[UIView alloc] initWithFrame:CGRectMake(11, _nextBtn.top - 120- 2*space- footer, self.view.width - 22,120)];
    [self.view addSubview:paramView];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, paramView.width, 40)];
    _slider1 = slider;
    [slider setMaximumValue:100];
    [slider setMinimumValue:-100];
    [slider setValue:0];
    [slider setMinimumTrackTintColor:[UIColor blackColor]];
    [slider setMaximumTrackTintColor:[UIColor colorWithHex:kTextGrayColor]];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [paramView addSubview:slider];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, slider.bottom + space, paramView.width, 40)];
    _slider2 = slider;
    [slider setMaximumValue:100];
    [slider setMinimumValue:-100];
    [slider setValue:0];
    [slider setMinimumTrackTintColor:[UIColor blackColor]];
    [slider setMaximumTrackTintColor:[UIColor colorWithHex:kTextGrayColor]];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [paramView addSubview:slider];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, slider.bottom + space, paramView.width, 40)];
    _slider3 = slider;
    [slider setMaximumValue:100];
    [slider setMinimumValue:-100];
    [slider setValue:0];
    [slider setMinimumTrackTintColor:[UIColor blackColor]];
    [slider setMaximumTrackTintColor:[UIColor colorWithHex:kTextGrayColor]];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [paramView addSubview:slider];
}

- (void)sliderValueChanged:(UISlider *)sender {
    CGFloat value = [sender value];
    NSLog(@"slider:%f",value);
}

- (void)layoutNextView {
    NSInteger buttonHeight = 45;
    NSInteger xfooter = 30 + buttonHeight;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn = nextBtn;
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
    D3ModelImageVC *vc = [[D3ModelImageVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
