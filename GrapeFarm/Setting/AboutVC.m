//
//  AboutVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/6/22.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "AboutVC.h"
#import "DeviceInfo.h"
#import "UIView+SizeUtility.h"

@interface AboutVC ()
@property (nonatomic, strong) UITableView           *aboutTableView;
@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:NSLocalizedString(@"about", nil)];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self layoutAboutTableView];
}

- (void)layoutAboutTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, self.view.frame.size.height - [DeviceInfo navigationBarHeight]) style:UITableViewStylePlain];
    [self setAboutTableView:tableView];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBounces:NO];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:tableView.frame.size.height/3];
    [self setTableViewFooterView:tableView.frame.size.height*2/3];
}

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _aboutTableView.frame.size.width, height)];
    [view setBackgroundColor:[UIColor clearColor]];
    CGFloat left = (_aboutTableView.frame.size.width - 120)/2.0;
    CGFloat top = (height-120)/2.0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 120, 120)];
    imageView.image = [UIImage imageNamed:@"logo"];
    [imageView.layer setCornerRadius:22.0];
    [imageView.layer setMasksToBounds:YES];
    [view addSubview:imageView];
    
    UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom,view.width,26)];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    [appNameLabel setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"AppName", nil),appVersion]];
    [appNameLabel setTextColor:[UIColor blackColor]];
    [appNameLabel setTextAlignment:NSTextAlignmentCenter];
    [appNameLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [view addSubview:appNameLabel];
    [_aboutTableView setTableHeaderView:view];
}


-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _aboutTableView.frame.size.width, height)];
    [view setBackgroundColor:[UIColor clearColor]];
    
//    UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, view.bottom - 30,view.width,30)];
//    [copyrightLabel setText:@"All copy right is reserved by HUOYAN Ltd., Changs China, 2019."];
//    [copyrightLabel setTextColor:[UIColor colorWithHex:kTextGrayColor]];
//    [copyrightLabel setTextAlignment:NSTextAlignmentCenter];
//    [copyrightLabel setFont:[UIFont boldSystemFontOfSize:12]];
//    [view addSubview:copyrightLabel];
    
    UITextView *appNameText = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, view.width - 20, height)];
    NSString *desc = NSLocalizedString(@"aboutText", nil);
    
    //段落样式
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paraStyle.lineSpacing = 5.0;
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.alignment = NSTextAlignmentJustified;
    //首行文本缩进
    paraStyle.firstLineHeadIndent = 20.0;
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:kTextGrayColor],NSParagraphStyleAttributeName:paraStyle};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:desc];
    [attrStr addAttributes:attributes range:NSMakeRange(0, desc.length)];
    [appNameText setAttributedText:attrStr];

    [view addSubview:appNameText];
    
    [_aboutTableView setTableFooterView:view];
}


@end
