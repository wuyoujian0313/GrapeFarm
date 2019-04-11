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


@interface RecordVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView        *listTableView;
@property (nonatomic,strong)RecordListBean     *records;
@end

@implementation RecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self demoData];
    [self setNavTitle:NSLocalizedString(@"Records",nil)];
    [self layoutListTableView];
}

- (void)demoData {
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 10; i ++) {
        RecordBean *_record = [[RecordBean alloc] init];
        _record.grapeName = [NSString stringWithFormat:@"grapeName-%d",i];
        _record.farmName = [NSString stringWithFormat:@"grapeName-%d",i];
        _record.latitude = [NSNumber numberWithFloat:111.123456];
        _record.longitude = [NSNumber numberWithFloat:111.123456];
        _record.timestamp = [NSString stringWithFormat:@"2019-04-11 10:00:%02d",i];
        _record.modelData = @"Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest ";
        
        [arr addObject:_record];
    }
    
    _records = [[RecordListBean alloc] init];
    [_records setRecords__Array__RecordBean:arr];
}

- (void)setRecordListBean:(RecordListBean *)records {
    _records = records;
}

- (void)layoutListTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.height) style:UITableViewStylePlain];
    [self setListTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBounces:NO];
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
    return [[_records getRecordList] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RecordDetailVC *vc = [[RecordDetailVC alloc] init];
    [vc setRecordBean:[_records getRecordList][indexPath.row]];
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
    
    RecordBean *record = [_records getRecordList][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",record.farmName,record.timestamp];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

@end
