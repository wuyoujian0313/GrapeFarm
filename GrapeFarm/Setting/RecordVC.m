//
//  RecordVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "RecordVC.h"
#import "LineView.h"
#import "DeviceInfo.h"
#import "UIView+SizeUtility.h"
#import "RecordDetailVC.h"
#import "NetworkTask.h"
#import "AILoadingView.h"
#import "FadePromptView.h"
#import "MJRefresh.h"
#import "RecordListBean.h"


@interface RecordVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate>
@property (nonatomic,strong)UITableView        *listTableView;
@property (nonatomic,strong)NSMutableArray     *records;
@property (nonatomic,assign)NSInteger          page;
@property (nonatomic,assign)NSInteger          pageSize;
@property (nonatomic,assign)NSInteger          totalPages;
@end

@implementation RecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"Records",nil)];
    [self layoutListTableView];
    [self loadFristRecords];
}

- (void)loadFristRecords {
    __weak typeof(self) wSelf = self;
    _listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        wSelf.page = 0;
        wSelf.pageSize = 100;
        [wSelf.records removeAllObjects];
        wSelf.records = [[NSMutableArray alloc] init];
        [wSelf requestRecordList];
        [wSelf.listTableView.mj_footer resetNoMoreData];
    }];
    
    [_listTableView.mj_header beginRefreshing];
}

- (void)loadMoreData {
    __weak typeof(self) wSelf = self;
    _listTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        wSelf.page ++;
        if (wSelf.page >= wSelf.totalPages) {
            //
            [wSelf.listTableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [wSelf requestRecordList];
        }
    }];
}

- (void)requestRecordList {
    NSDictionary *params = @{@"page":[NSNumber numberWithInteger:_page],
                             @"size":[NSNumber numberWithInteger:_pageSize],
                             };
    [[NetworkTask sharedNetworkTask] startGETTaskApi:kAPIRecord
                                            forParam:params
                                            delegate:self
                                           resultObj:[[RecordListBean alloc] init]
                                          customInfo:@"records"];
}


- (void)layoutListTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.height) style:UITableViewStylePlain];
    [self setListTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:tableView];
    [self setTableViewFooterView:0];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _listTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_listTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_records count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RecordDetailVC *vc = [[RecordDetailVC alloc] init];
    [vc setRecordBean:_records[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"ccontentTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    RecordBean *record = _records[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",record.farmName,record.createTime];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}


#pragma mark - NetworkTaskDelegate
- (void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    if ([customInfo isEqualToString:@"records"]) {
        if (_records) {
            if ([_records count] == 0) {
                [self loadMoreData];
            }
            RecordListBean *bean = (RecordListBean *)result;
            [_records addObjectsFromArray:[bean getRecordList]];
            _totalPages = [bean.totalPages integerValue];
            if(_page >= _totalPages) {
                [_listTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        [_listTableView reloadData];
    }
    
    [self endRefresh];
}


- (void)endRefresh {
    if ([_listTableView.mj_header isRefreshing]) {
        [_listTableView.mj_header endRefreshing];
    }
    if ([_listTableView.mj_footer isRefreshing]) {
        [_listTableView.mj_footer endRefreshing];
    }
}

- (void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [self endRefresh];
    [FadePromptView showPromptStatus:errorDesc duration:1.5 finishBlock:^{
    }];
}

@end
