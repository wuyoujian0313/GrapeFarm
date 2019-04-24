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
#import "OpenCVWrapper.h"


typedef NS_ENUM(NSInteger ,ColorType) {
    ColorType_toRed = 0,
    ColorType_toBlue = 1,
    ColorType_toGreen = 2,
};


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

- (void)setColorSegImage:(ColorType)type {
    FileCache *fileCache = [FileCache sharedFileCache];
    NSData *imageData = [fileCache dataFromCacheForKey:kCroppedImageFileKey];
    UIImage *image = [UIImage imageWithData:imageData];
    switch (type) {
        case ColorType_toRed:
            image = [OpenCVWrapper toRed:image];
            break;
        case ColorType_toBlue:
            image = [OpenCVWrapper toBlue:image];
            break;
        case ColorType_toGreen:
            image = [OpenCVWrapper toGreen:image];
            break;
            
        default:
            break;
    }
    
    [self reLayoutImageView:image];
}

- (void)layoutSegmentControl {
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"ToRed",@"ToBlue",@"ToGreen",nil];
    _segmentCtl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentCtl.frame = CGRectMake(11,15 + [DeviceInfo navigationBarHeight],self.view.frame.size.width - 22,30);
    _segmentCtl.selectedSegmentIndex = 0;
    _segmentCtl.tintColor = [UIColor blackColor];
    [_segmentCtl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentCtl];
}

- (void)segmentAction:(UISegmentedControl *)sender {
    [self setColorSegImage:(ColorType)sender.selectedSegmentIndex];
}

- (void)reLayoutImageView:(UIImage *)image {
    NSInteger imageViewSize = self.view.width - 20;
    NSInteger top = 20;
    NSInteger areaHeight = _nextBtn.top - _segmentCtl.bottom - 2*top;
    [_imageView setImage:nil];
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
            [_imageView setTop:top + _segmentCtl.bottom];
        } else {
            [_imageView setHeight:h];
            [_imageView setTop:(areaHeight-h)/2.0 +_segmentCtl.bottom + top];
        }
    } else {
        // 以高度为准
        if (image.size.height >= areaHeight) {
            CGFloat w = image.size.width/image.size.height * areaHeight;
            [_imageView setLeft:(imageViewSize-w)/2.0];
            [_imageView setWidth:w];
            [_imageView setTop:_segmentCtl.bottom + top];
            [_imageView setHeight:areaHeight];
        } else {
            // 以实际为准,
            [_imageView setLeft:(imageViewSize-image.size.width)/2.0 + 10];
            [_imageView setTop:(areaHeight-image.size.height)/2.0 +  _segmentCtl.bottom + top];
            
            [_imageView setWidth:image.size.width];
            [_imageView setHeight:image.size.height];
        }
    }
}

- (void)layoutColorSegmentImageView {
    NSInteger imageViewSize = self.view.width - 20;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, _segmentCtl.bottom + 10, imageViewSize, imageViewSize)];
    [_imageView setBackgroundColor:[UIColor clearColor]];
    [_imageView.layer setCornerRadius:10];
    [_imageView setClipsToBounds:YES];
    [self.view addSubview:_imageView];
    
    ColorType type = 0;
    [_segmentCtl setSelectedSegmentIndex:type];
    [self setColorSegImage:type];
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
//    kColorSegImageFileKey
    FileCache *fileCache = [FileCache sharedFileCache];
    [fileCache writeData:UIImagePNGRepresentation(_imageView.image) forKey:kColorSegImageFileKey];
    ModelIdentificationVC *vc = [[ModelIdentificationVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
