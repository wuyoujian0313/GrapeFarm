//
//  RecordDetailVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "RecordDetailVC.h"
#import "LineView.h"
#import "DeviceInfo.h"
#import "UIView+SizeUtility.h"


@interface RecordDetailVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView        *contentTableView;
@property (nonatomic,strong)UITextView         *textView;
@property (nonatomic,strong)RecordBean          *record;
@end

@implementation RecordDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:_record.createTime];
    [self layoutContentTableView];
}

- (void)setRecordBean:(RecordBean *)record {
    _record = record;
}

- (void)layoutContentTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.height) style:UITableViewStyleGrouped];
    [self setContentTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBounces:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:tableView.height - 10 - 3*45 - [DeviceInfo navigationBarHeight]];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentTableView.frame.size.width, height)];
    [_contentTableView setTableHeaderView:view];
}

- (void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentTableView.frame.size.width, height)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, view.width-22, 30)];
    [label setText:NSLocalizedString(@"ModelData", nil)];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:14.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [view addSubview:label];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(11, label.bottom, view.width - 22, view.height - label.height - 10)];
    [_textView setFont:[UIFont systemFontOfSize:14.0]];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    [_textView setEditable:NO];
    [_textView setSelectable:NO];
    [_textView setText:_record.modelData];
    [view addSubview:_textView];
    
    [_contentTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"ccontentTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        // 农庄
        [cell.imageView setImage:[UIImage imageNamed:@"home"]];
        cell.textLabel.text = _record.farmName;
    } else if (indexPath.row == 1) {
        // 葡萄种类
        [cell.imageView setImage:[UIImage imageNamed:@"grape"]];
        cell.textLabel.text = _record.grapeName;
    } else if(indexPath.row == 2) {
        [cell.imageView setImage:[UIImage imageNamed:@"address"]];
        cell.textLabel.text = [NSString stringWithFormat:@"Lng:%f, Lat:%f",[_record.longitude floatValue],[_record.latitude floatValue]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section

@end
