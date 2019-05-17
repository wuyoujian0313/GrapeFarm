//
//  FarmListVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "FarmListVC.h"
#import "LineView.h"
#import "SaveSimpleDataManager.h"
#import "NetworkTask.h"
#import "AILoadingView.h"
#import "FadePromptView.h"
#import "FarmListBean.h"

@interface FarmListVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,NetworkTaskDelegate>
@property (nonatomic, strong) UITableView           *farmTableView;
@property (nonatomic, strong) NSMutableArray        *farms;
@property (nonatomic, copy) NSString                *farmName;
@property (nonatomic, assign) BOOL                  isSave;
@property (nonatomic, assign) NSInteger             selIndex;
@end

@implementation FarmListVC

- (void)dealloc {
    
}

- (void)setFarmName:(NSString *)farmName saveToConfig:(BOOL)isSave {
    _farmName = farmName;
    _isSave = isSave;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"Farm",nil)];
    [self layoutFarmTableView];
    [self requestFarmList];
}

- (void)requestFarmList {
    [[NetworkTask sharedNetworkTask] startGETTaskApi:kAPIFarm
                                            forParam:nil
                                            delegate:self
                                           resultObj:[[FarmListBean alloc] init]
                                          customInfo:@"farm"];
}

- (void)configFarms {
    _selIndex = -1;
    if (_farmName != nil && [_farmName length] > 0) {
        for (NSInteger i = 0; i < [_farms count]; i++) {
            NSString *name = _farms[i];
            if ([name isEqualToString:_farmName]) {
                _selIndex = i;
                break;
            }
        }
        
        if (_selIndex == -1) {
            [_farms addObject:_farmName];
            _selIndex = [_farms count] - 1;
        }
    } else {
        _selIndex = 0;
        [self saveToConfig];
    }
    
    [_farmTableView reloadData];
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

- (void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _farmTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_farmTableView setTableFooterView:view];
}

-(void)saveToConfig {
    if (_isSave) {
        SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
        [manager setObject:_farms[_selIndex] forKey:kMyfarmUserdefaultKey];
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectedFarmName:)]) {
        [_delegate didSelectedFarmName:_farms[_selIndex]];
    }
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
    
    NSInteger oldRow = _selIndex;
    _selIndex  = indexPath.row;
    [tableView reloadRowsAtIndexPaths:
     @[indexPath,[NSIndexPath indexPathForRow:oldRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    //保存配置
    [self saveToConfig];
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

    cell.textLabel.text = [_farms objectAtIndex:indexPath.row];
    NSString *icon = @"radio-off";
    if (_selIndex == indexPath.row) {
        icon = @"radio-on";
    }
    
    [(UIImageView*)cell.accessoryView setImage:[UIImage imageNamed:icon]];
    
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
    if ([customInfo isEqualToString:@"farm"]) {
        if (self.farms == nil) {
            self.farms = [[NSMutableArray alloc] initWithCapacity:0];
        }
        
        FarmListBean *bean = (FarmListBean *)result;
        NSArray *list = [bean getFarmList];
        if (list && [list count] > 0) {
            [_farms addObjectsFromArray:list];
        }
        
        [self configFarms];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [AILoadingView dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:2.0 finishBlock:^{
        //
    }];
}

@end
