//
//  FarmListVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "FarmListVC.h"
#import "LineView.h"

@interface FarmListVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView           *farmTableView;
@property (nonatomic, strong) NSArray               *farms;
@end

@implementation FarmListVC

-(void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"Farm",nil)];
    [self configFarms];
    [self layoutFarmTableView];
}

- (void)configFarms {
    self.farms = @[@{@"name":@"Farm1",@"icon":@"selected"},
                      @{@"name":@"Farm2",@"icon":@"unSelected"},
                      @{@"name":@"Farm3",@"icon":@"unSelected"},
                      @{@"name":@"Farm4",@"icon":@"unSelected"}];
}

- (void)layoutFarmTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self setFarmTableView:tableView];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:0];
}

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _farmTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_farmTableView setTableHeaderView:view];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
    [_farmTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _farmTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_farmTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_farms count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"farmsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        cell.accessoryView = imageView;
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
    }
    
    NSDictionary *config = [_farms objectAtIndex:indexPath.row];
    cell.textLabel.text = config[@"name"];
    [(UIImageView*)cell.accessoryView setImage:[UIImage imageNamed:config[@"icon"]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

@end
