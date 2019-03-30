//
//  ColorSegment?VC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/29.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "ColorSegmentVC.h"
#import "DeviceInfo.h"

@interface ColorSegmentVC ()
@property(nonatomic,strong)UISegmentedControl *segmentCtl;
@end

@implementation ColorSegmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ColorSegment",nil)];
    [self layoutSegmentControl];
}

- (void)layoutSegmentControl {
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"分割一",@"分割二",@"分割三",nil];
    _segmentCtl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentCtl.frame = CGRectMake(11,15 + [DeviceInfo navigationBarHeight],self.view.frame.size.width - 22,30);
    _segmentCtl.selectedSegmentIndex = 0;
    _segmentCtl.tintColor = [UIColor blackColor];
    [self.view addSubview:_segmentCtl];
}



@end
