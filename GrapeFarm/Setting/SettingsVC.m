//
//  SettingsVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "SettingsVC.h"
#import "DeviceInfo.h"
#import "AppDelegate.h"
#import "ForgotPasswordVC.h"
#import "RecordVC.h"
#import "FarmListVC.h"


@interface SettingsVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView           *abilityTableView;
@property (nonatomic, strong) NSArray               *abilitys;
@end

@implementation SettingsVC

-(void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"Settings",nil)];
    [self configAbilitys];
    [self layoutSettingsTableView];
}

- (void)configAbilitys {
    self.abilitys = @[@{@"name":NSLocalizedString(@"Records",nil),@"icon":@"address"},
                      @{@"name":NSLocalizedString(@"MyFarm",nil),@"icon":@"button"},
                      @{@"name":NSLocalizedString(@"ModifyPassword",nil),@"icon":@"button"},
                      @{@"name":NSLocalizedString(@"Quit",nil),@"icon":@"button"}];
}

- (void)layoutSettingsTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [self setAbilityTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
}

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _abilityTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_abilityTableView setTableHeaderView:view];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_abilitys count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        // 历史记录
        RecordVC *vc = [[RecordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (row == 1) {
        // 我的农庄
        FarmListVC *vc = [[FarmListVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (row == 2) {
        // 修改密码
        ForgotPasswordVC *vc = [[ForgotPasswordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (row == 3) {
        
        UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Logout", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                           destructiveButtonTitle:NSLocalizedString(@"Quit", nil)
                                                otherButtonTitles:nil];
        [sheet showInView:self.view];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"abilitysTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSDictionary *config = [_abilitys objectAtIndex:indexPath.row];
    cell.textLabel.text = config[@"name"];
    [cell.imageView setImage:[UIImage imageNamed:config[@"icon"]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        AppDelegate *app = [AppDelegate shareMyApplication];
        [app switchToLoginPage];
    }
}


@end
