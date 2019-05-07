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
#import "OpenCVWrapper.h"
#import "EdgeImageView.h"
#import "AILoadingView.h"

@interface ModelIdentificationVC ()
@property(nonatomic,strong)UIButton *nextBtn;
@property(nonatomic,strong)UIView *paramView;
@property(nonatomic,strong)UIStepper *stepper1;
@property(nonatomic,strong)UIStepper *stepper2;
@property(nonatomic,strong)UIStepper *stepper3;
@property(nonatomic,strong)EdgeImageView *imageView;

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
    NSData *imageData = [fileCache dataFromCacheForKey:kColorSegImageFileKey];
    UIImage *image = [UIImage imageWithData:imageData];
//    UIImage *image = [OpenCVWrapper Rededge: [UIImage imageWithData:imageData] value1:28 value2:50 value3:100];
    
    [self reLayoutImageView:image];
}

- (void)layoutColorImageView {
    NSInteger top = 10 + [DeviceInfo navigationBarHeight];
    NSInteger imageViewSize = self.view.width - 20;
    _imageView = [[EdgeImageView alloc] initWithFrame:CGRectMake(10, top, imageViewSize, imageViewSize)];
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
    NSInteger footer = 10;
    NSInteger space = 10;
    NSInteger paramHeight = 120 + 3*space;
    UIView *paramView = [[UIView alloc] initWithFrame:CGRectMake(11, _nextBtn.top - paramHeight- footer, self.view.width - 22,paramHeight)];
    _paramView = paramView;
    [self.view addSubview:paramView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, space, 220, 40)];
    [label setText:NSLocalizedString(@"Threshold", nil)];
    [label setFont:[UIFont boldSystemFontOfSize:18.0]];
    [label setTextColor:[UIColor blackColor]];
    [paramView addSubview:label];
    
    //第一个 25到30，第二个50到60，第三个100到110
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(paramView.width - 80 - 11 , space, 80, 0)];
    _stepper1 = stepper;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [stepper setTintColor:[UIColor blackColor]];
    [stepper setMinimumValue:25];
    [stepper setValue:0];
    [stepper setMaximumValue:30];
    [stepper setStepValue:1];
    [paramView addSubview:stepper];
    [stepper setTop:stepper.top + (40-stepper.height)/2.0];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, space + label.bottom, 220, 40)];
    [label setText:NSLocalizedString(@"MinRadius", nil)];
    [label setFont:[UIFont boldSystemFontOfSize:18.0]];
    [label setTextColor:[UIColor blackColor]];
    [paramView addSubview:label];
    
    stepper = [[UIStepper alloc] initWithFrame:CGRectMake(paramView.width - 80 - 11 , label.top, 80, 0)];
    _stepper2 = stepper;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [stepper setTintColor:[UIColor blackColor]];
    [stepper setMinimumValue:50];
    [stepper setValue:0];
    [stepper setMaximumValue:60];
    [stepper setStepValue:1];
    [paramView addSubview:stepper];
    [stepper setTop:stepper.top + (40-stepper.height)/2.0];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, space + label.bottom, 220, 40)];
    [label setText:NSLocalizedString(@"MaxRadius", nil)];
    [label setFont:[UIFont boldSystemFontOfSize:18.0]];
    [label setTextColor:[UIColor blackColor]];
    [paramView addSubview:label];
    
    stepper = [[UIStepper alloc] initWithFrame:CGRectMake(paramView.width - 80 - 11 , label.top, 80, 0)];
    _stepper3 = stepper;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [stepper setTintColor:[UIColor blackColor]];
    [stepper setMinimumValue:100];
    [stepper setValue:0];
    [stepper setMaximumValue:110];
    [stepper setStepValue:1];
    [paramView addSubview:stepper];
    [stepper setTop:stepper.top + (40-stepper.height)/2.0];
}

- (void)stepperValueChanged:(UIStepper *)sender {
    NSInteger value1 = ceil(_stepper1.value);
    NSInteger value2 = ceil(_stepper2.value);
    NSInteger value3 = ceil(_stepper3.value);
    
    [AILoadingView show:@"识别中..."];
#if 1
    NSArray *arr = [OpenCVWrapper edgeCircles: _imageView.image value1:value1 value2:value2 value3:value3 value4:_type];
    [_imageView setCircles:arr];
#else
    UIImage *image = [OpenCVWrapper Rededge: _imageView.image value1:value1 value2:value2 value3:value3];
    _imageView.image = nil;
    _imageView.image = image;
#endif
    [AILoadingView dismiss];
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
