//
//  GoodListVC.m
//  3DBunch
//
//  Created by Wu YouJian on 2019/10/8.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "GoodListVC.h"
#import "LineView.h"
#import "AILoadingView.h"
#import "FadePromptView.h"
#import "GoodsListBean.h"
#import "NetworkTask.h"
#import "PaypalWebViewVC.h"


@interface GoodListVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate>
@property (nonatomic, strong) UITableView           *goodsTableView;
@property (nonatomic, strong) NSMutableArray        *goods;
@end

@implementation GoodListVC

- (void)dealloc {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"VIPGoods",nil)];
    [self layoutFarmTableView];
    [self requestGoodsList];
}

- (void)requestGoodsList {
    [[NetworkTask sharedNetworkTask] startGETTaskApi:kAPIVIPGoods
                                            forParam:nil
                                            delegate:self
                                           resultObj:[[GoodsListBean alloc] init]
                                          customInfo:@"goods"];
}

- (void)layoutFarmTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self setGoodsTableView:tableView];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:0];
}

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _goodsTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_goodsTableView setTableHeaderView:view];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
    [_goodsTableView setTableHeaderView:view];
}

- (void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _goodsTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_goodsTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_goods count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GoodsBean *bean = [_goods objectAtIndex:indexPath.row];
    PaypalWebViewVC *vc = [[PaypalWebViewVC alloc] init];
    vc.type = [bean.type integerValue];
    vc.amount = [bean.amount integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"goodsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
    }
    
    GoodsBean *bean = [_goods objectAtIndex:indexPath.row];
    cell.textLabel.text = bean.name;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [AILoadingView dismiss];
    if ([customInfo isEqualToString:@"goods"]) {
        if (self.goods == nil) {
            self.goods = [[NSMutableArray alloc] initWithCapacity:0];
        }
        
        GoodsListBean *bean = (GoodsListBean *)result;
        [self.goods addObjectsFromArray:[bean getGoodsList]];
        [_goodsTableView reloadData];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [AILoadingView dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:2.0 finishBlock:^{
        //
    }];
}

@end
