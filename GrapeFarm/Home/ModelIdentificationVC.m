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
#import "FileCache.h"
#import "GLKD3ModelVC.h"

@interface ModelIdentificationVC ()
@property(nonatomic,strong)UIButton *nextBtn;
@property(nonatomic,strong)UIView *paramView;
@property(nonatomic,strong)UISlider *slider1;
@property(nonatomic,strong)UISlider *slider2;
@property(nonatomic,strong)UISlider *slider3;
@property(nonatomic,strong)UIImageView *imageView;

@end

@implementation ModelIdentificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ModelIdentification", nil)];
    [self layoutNextView];
    [self layoutColorImageView];
    [self layoutParamView];
    
    FileCache *fileCache = [FileCache sharedFileCache];
    NSData *imageData = [fileCache dataFromCacheForKey:kCroppedImageFileKey];
    [self reLayoutImageView:[UIImage imageWithData:imageData]];
}

- (void)layoutColorImageView {
    NSInteger top = 10 + [DeviceInfo navigationBarHeight];
    NSInteger imageViewSize = self.view.width - 20;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, top, imageViewSize, imageViewSize)];
    [_imageView.layer setCornerRadius:10];
    [_imageView setClipsToBounds:YES];
    [self.view addSubview:_imageView];
}

- (void)reLayoutImageView:(UIImage *)image {
    NSInteger imageViewSize = self.view.width - 20;
    NSInteger areaHeight = _paramView.top - [DeviceInfo navigationBarHeight] - 10;
    // 需要调用中南大学的核心库计算分离之后的image
    [_imageView setImage:image];
    
    if (image.size.width >= imageViewSize) {
        // 以宽度为准
        CGFloat h = image.size.height/image.size.width * imageViewSize;
        if (h >= areaHeight) {
            // 以高度为准缩放宽度
            [_imageView setHeight:areaHeight];
            CGFloat w = image.size.width/image.size.height * areaHeight;
            [_imageView setLeft:(self.view.width - w)/2.0];
            [_imageView setWidth:w];
        } else {
            [_imageView setHeight:h];
            [_imageView setTop:(areaHeight-h)/2.0 + 10 + [DeviceInfo navigationBarHeight]];
        }
    } else {
        // 以高度为准
        if (image.size.height >= areaHeight) {
            CGFloat w = image.size.width/image.size.height * imageViewSize;
            [_imageView setLeft:(imageViewSize-w)/2.0];
            [_imageView setWidth:w];
            [_imageView setHeight:areaHeight];
        } else {
            // 以实际为准,
            [_imageView setTop:(areaHeight-image.size.height)/2.0 + 10 + [DeviceInfo navigationBarHeight]];
            [_imageView setLeft:(imageViewSize-image.size.width)/2.0 + 10];
            [_imageView setWidth:image.size.width];
            [_imageView setHeight:image.size.height];
        }
    }
}

- (void)layoutParamView {
    NSInteger maximumValue = 100;
    NSInteger minimumValue = -100;
    NSInteger footer = 10;
    NSInteger space = 10;
    NSInteger paramHeight = 120 + 3*space;
    UIView *paramView = [[UIView alloc] initWithFrame:CGRectMake(11, _nextBtn.top - paramHeight- footer, self.view.width - 22,paramHeight)];
    _paramView = paramView;
    [self.view addSubview:paramView];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, space, paramView.width, 40)];
    _slider1 = slider;
    [slider setMaximumValue:maximumValue];
    [slider setMinimumValue:minimumValue];
    [slider setValue:(maximumValue+minimumValue)/2.0];
    [slider setMinimumTrackTintColor:[UIColor blackColor]];
    [slider setMaximumTrackTintColor:[UIColor colorWithHex:kTextGrayColor]];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [paramView addSubview:slider];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, slider.bottom + space, paramView.width, 40)];
    _slider2 = slider;
    [slider setMaximumValue:maximumValue];
    [slider setMinimumValue:minimumValue];
    [slider setValue:(maximumValue+minimumValue)/2.0];
    [slider setMinimumTrackTintColor:[UIColor blackColor]];
    [slider setMaximumTrackTintColor:[UIColor colorWithHex:kTextGrayColor]];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [paramView addSubview:slider];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, slider.bottom + space, paramView.width, 40)];
    _slider3 = slider;
    [slider setMaximumValue:maximumValue];
    [slider setMinimumValue:minimumValue];
    [slider setValue:(maximumValue+minimumValue)/2.0];
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
    NSInteger xfooter = 15 + buttonHeight;
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
    GLKD3ModelVC *vc = [[GLKD3ModelVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
