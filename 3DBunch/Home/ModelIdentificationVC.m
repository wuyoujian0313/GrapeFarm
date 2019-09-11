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
#import "OpenCVWrapper.h"
#import "EdgeImageView.h"
#import "AILoadingView.h"
#import "AIRangeSliderView.h"
#import "SaveSimpleDataManager.h"
#import "SCN3DModelVC.h"
#import "AICircle.h"
#import "FadePromptView.h"

@interface ModelIdentificationVC ()<AIRangeSliderViewDelegate>
@property(nonatomic,strong)UIButton *nextBtn;
@property(nonatomic,strong)UIView *paramView;
@property(nonatomic,strong)AIRangeSliderView *rangeSlider;
@property(nonatomic,strong)UIStepper *stepper;
@property(nonatomic,strong)EdgeImageView *imageView;

@property(nonatomic,assign)NSInteger leftValue;
@property(nonatomic,assign)NSInteger rightValue;
@property(nonatomic,strong)NSMutableArray *imageCircles;
@property(nonatomic,strong)NSNumber *colorIndex;
@property(nonatomic,assign)NSInteger threshold;
@end

@implementation ModelIdentificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ModelIdentification", nil)];
    [self layoutNextView];
    [self layoutColorImageView];
    [self layoutParamView];
    [self reLayoutImageView];
    self.imageCircles = [[NSMutableArray alloc] initWithCapacity:0];
    
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    self.colorIndex = [manager objectForKey:kGrapeColorIndexUserdefaultKey];
    
    [FadePromptView showPromptStatus:NSLocalizedString(@"RadiusLess", nil) duration:5.0 finishBlock:^{
        //
    }];
}

- (void)layoutColorImageView {
    NSInteger top = 10 + [DeviceInfo navigationBarHeight];
    NSInteger imageViewSize = self.view.width - 20;
    _imageView = [[EdgeImageView alloc] initWithFrame:CGRectMake(10, top, imageViewSize, imageViewSize)];
    [_imageView.layer setCornerRadius:10];
    [_imageView setClipsToBounds:YES];
    [self.view addSubview:_imageView];
}

- (void)reLayoutImageView {
    
    FileCache *fileCache = [FileCache sharedFileCache];
    NSData *imageData = [fileCache dataFromCacheForKey:kColorSegImageFileKey];
    UIImage *image = [UIImage imageWithData:imageData];
    
    NSInteger imageViewSize = self.view.width - 20;
    NSInteger areaHeight = _paramView.top - 60 - [DeviceInfo navigationBarHeight] - 10;
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
//            [_imageView setTop:(areaHeight-h)/2.0 + 10 + [DeviceInfo navigationBarHeight]];
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
//            [_imageView setTop:(areaHeight-image.size.height)/2.0 + 10 + [DeviceInfo navigationBarHeight]];
            [_imageView setLeft:(imageViewSize-image.size.width)/2.0 + 10];
            [_imageView setWidth:image.size.width];
            [_imageView setHeight:image.size.height];
        }
    }
    
    [_rangeSlider setMinValue:0];
    [_rangeSlider setMaxValue:_imageView.width];
    _leftValue = (_rangeSlider.minValue + _rangeSlider.maxValue)/2;
    _rightValue =_leftValue;
    [_rangeSlider setLeftValue:_leftValue];
    [_rangeSlider setRightValue:_rightValue];
}

- (void)layoutParamView {
    
    self.rangeSlider = [[AIRangeSliderView alloc] initWithFrame:CGRectMake(11, _imageView.top, self.view.width - 22, _nextBtn.top - _imageView.top - 80) delegate:self];
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    NSNumber *color = [manager objectForKey:kBrushColorUserdefaultKey];
    [_rangeSlider setVernierLineColor:[UIColor colorWithHex:[color integerValue]]];
    [self.view addSubview:_rangeSlider];
    
    NSInteger space = 10;
    UIView *paramView = [[UIView alloc] initWithFrame:CGRectMake(11, _rangeSlider.bottom + space,  self.view.width - 22,60)];
    _paramView = paramView;
    [self.view addSubview:paramView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, space, 220, 40)];
    [label setText:NSLocalizedString(@"Threshold", nil)];
    [label setFont:[UIFont boldSystemFontOfSize:18.0]];
    [label setTextColor:[UIColor blackColor]];
    [paramView addSubview:label];
    
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(paramView.width - 80 - 11 , space, 80, 0)];
    _stepper = stepper;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [stepper setTintColor:[UIColor blackColor]];
    [stepper setMinimumValue:25];
    [stepper setValue:25];
    [stepper setMaximumValue:40];
    [stepper setStepValue:1];
    [paramView addSubview:stepper];
    [stepper setTop:stepper.top + (40-stepper.height)/2.0];
}

- (void)circleEdge {
    NSInteger distance = _rightValue - _leftValue;
    if (distance <= 0) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"RadiusLess", nil) duration:1.5 finishBlock:^{
            //
        }];
        [_stepper setValue:_threshold];
        return;
    }
    
    [AILoadingView show:NSLocalizedString(@"Identifying", nil)];
    NSInteger scale = _imageView.image.size.width/_imageView.width;
    distance *=scale;
    _threshold = ceil(_stepper.value);
    
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self ) wSelf = self;
    dispatch_async(queue, ^{
        typeof(self) sSelf = wSelf;
        FileCache *fileCache = [FileCache sharedFileCache];
        NSData *imageData = [fileCache dataFromCacheForKey:kCroppedImageFileKey];
        UIImage *image = [UIImage imageWithData:imageData];
        NSArray *arr = [OpenCVWrapper edgeCircles:image threshold:sSelf.threshold distance:distance type:sSelf.type gtype:[sSelf.colorIndex integerValue]];
        [sSelf.imageCircles removeAllObjects];
        for (AICircle *c in arr) {
            AICircle *cc = [[AICircle alloc] init];
            cc.x =  [NSNumber numberWithFloat:[c.x floatValue]];
            cc.y =  [NSNumber numberWithFloat:[c.y floatValue]];
            cc.r =  [NSNumber numberWithFloat:[c.r floatValue]];
            cc.z =  [NSNumber numberWithFloat:[c.z integerValue]];
            [sSelf.imageCircles addObject:cc];
        }
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            // 追加在主线程中执行的任务
            [sSelf.imageView setCircles:arr];
            [AILoadingView dismiss];
        });
    });
}

- (void)stepperValueChanged:(UIStepper *)sender {
    [self circleEdge];
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
//    GLKD3ModelVC *vc = [[GLKD3ModelVC alloc] init];
    if(_imageCircles == nil || [_imageCircles count] == 0){
        //no_identifying
        [FadePromptView showPromptStatus:NSLocalizedString(@"no_identifying", nil) duration:1.5 finishBlock:^{
            //
        }];
        return;
    }
        
    SCN3DModelVC *vc = [[SCN3DModelVC alloc] init];
    [vc setCircleEdges:_imageCircles];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - AIRangeSliderViewDelegate
- (void)sliderValueDidChangedOfLeft:(NSInteger)left right:(NSInteger)right {
    _leftValue = left;
    _rightValue = right;
    NSLog(@"left:%ld,right:%ld",(long)_leftValue,(long)_rightValue);
    if (_rightValue - _leftValue > 0) {
        [self circleEdge];
    } else {
        [_imageView clear];
    }
}

- (void)sliderValueChangingOfLeft:(NSInteger)left right:(NSInteger)right {
    [_imageView clear];
}


@end
