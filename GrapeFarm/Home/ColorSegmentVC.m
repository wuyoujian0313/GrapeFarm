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
#import "FileCache.h"
#import "UIView+SizeUtility.h"

@interface ColorSegmentVC ()
@property(nonatomic,strong)UISegmentedControl *segmentCtl;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIButton *nextBtn;
@end

@implementation ColorSegmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ColorSegment",nil)];
    [self layoutSegmentControl];
    [self layoutNextView];
    [self layoutColorSegmentImageView];
}

- (void)layoutSegmentControl {
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"分割一",@"分割二",@"分割三",nil];
    _segmentCtl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentCtl.frame = CGRectMake(11,15 + [DeviceInfo navigationBarHeight],self.view.frame.size.width - 22,30);
    _segmentCtl.selectedSegmentIndex = 0;
    _segmentCtl.tintColor = [UIColor blackColor];
    [self.view addSubview:_segmentCtl];
}

- (void)reLayoutImageView:(UIImage *)image {
    NSInteger imageViewSize = self.view.width - 20;
    NSInteger areaHeight = _nextBtn.top - _segmentCtl.bottom;
    // 需要调用中南大学的核心库计算分离之后的image
    [_imageView setImage:image];
    
    if (image.size.width >= imageViewSize) {
        // 以宽度为准
        CGFloat h = image.size.height/image.size.width * imageViewSize;
        [_imageView setHeight:h];
        [_imageView setTop:(areaHeight-h)/2.0 + [DeviceInfo navigationBarHeight] + _segmentCtl.height + 10];
        
    } else {
        // 以高度为准
        if (image.size.height >= imageViewSize) {
            CGFloat w = image.size.width/image.size.height * imageViewSize;
            [_imageView setLeft:(imageViewSize-w)/2.0];
            [_imageView setWidth:w];
            [_imageView setTop:(areaHeight-imageViewSize)/2.0 + [DeviceInfo navigationBarHeight] + _segmentCtl.height + 10];
        } else {
            // 以实际为准,
            [_imageView setLeft:(imageViewSize-image.size.width)/2.0 + 10];
            [_imageView setTop:(areaHeight-image.size.height)/2.0 + [DeviceInfo navigationBarHeight] + _segmentCtl.height + 10];
            
            [_imageView setWidth:image.size.width];
            [_imageView setHeight:image.size.height];
        }
    }
}

- (void)layoutColorSegmentImageView {
    NSInteger imageViewSize = self.view.width - 20;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, _segmentCtl.bottom + 10, imageViewSize, imageViewSize)];
    [_imageView.layer setCornerRadius:10];
    [_imageView setClipsToBounds:YES];
    [self.view addSubview:_imageView];
    
    FileCache *fileCache = [FileCache sharedFileCache];
    NSData *imageData = [fileCache dataFromCacheForKey:kCroppedImageFileKey];
    [self reLayoutImageView:[UIImage imageWithData:imageData]];
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
    ModelIdentificationVC *vc = [[ModelIdentificationVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
