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
#import "UIView+SizeUtility.h"
#import "SetBrushColorVC.h"
#import "SaveSimpleDataManager.h"

@interface SettingsVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,FarmSelectIndexDelegate,ColorSelectIndexDelegate>
@property (nonatomic, strong) UITableView           *abilityTableView;
@property (nonatomic, strong) NSArray               *abilitys;
@property (nonatomic, copy) NSString                *myFarmName;
@property (nonatomic, assign) NSInteger             brushColor;
@property (nonatomic, copy) NSString                *brushColorName;
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
    self.abilitys = @[@{@"name":NSLocalizedString(@"Records",nil),@"icon":@"history"},
                      @{@"name":NSLocalizedString(@"MyFarm",nil),@"icon":@"home"},
                      @{@"name":NSLocalizedString(@"ModifyPassword",nil),@"icon":@"edit"},
                      @{@"name":NSLocalizedString(@"BrushColor",nil),@"icon":@"palette"},
                      @{@"name":NSLocalizedString(@"Quit",nil),@"icon":@"exit"}];
    
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    NSString *farmName = [manager objectForKey:kMyfarmUserdefaultKey];
    if (farmName != nil && [farmName length] > 0) {
        _myFarmName = farmName;
    }
    
    NSNumber *color = [manager objectForKey:kBrushColorUserdefaultKey];
    NSString *colorName = [manager objectForKey:kBrushColorNameUserdefaultKey];
    if (color != nil) {
        _brushColor = [color integerValue];
        _brushColorName = colorName;
    } else {
        _brushColor = 0xF3704B;
        _brushColorName = @"Red";
        [manager setObject:[NSNumber numberWithInteger:_brushColor] forKey:kBrushColorUserdefaultKey];
        [manager setObject:_brushColorName forKey:kBrushColorNameUserdefaultKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kBrushColorChangeNotification object:nil userInfo:nil];
    }
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

#pragma mark - FarmSelectIndexDelegate
-(void)didSelectedFarmName:(NSString *)farmName {
    _myFarmName = farmName;
    
    [_abilityTableView reloadRowsAtIndexPaths:
     @[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ColorSelectIndexDelegate
- (void)didSelectedColorValue:(NSInteger)color colorName:(NSString *)colorName {
    _brushColor = color;
    _brushColorName = colorName;
    [_abilityTableView reloadRowsAtIndexPaths:
     @[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        vc.delegate = self;
        SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
        NSNumber *farmIndex = [manager objectForKey:kMyfarmUserdefaultKey];
        if (farmIndex != nil) {
            [vc setFarmName:_myFarmName saveToConfig:YES];
        } else {
            [manager setObject:[NSNumber numberWithInteger:0] forKey:kMyfarmUserdefaultKey];
            [vc setFarmName:@"" saveToConfig:YES];
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if (row == 2) {
        // 修改密码
        ForgotPasswordVC *vc = [[ForgotPasswordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (row == 3) {
        // 画笔颜色
        SetBrushColorVC *vc = [[SetBrushColorVC alloc] init];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (row == 4) {
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
    
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:[cell.detailTextLabel.font pointSize]];
    if (indexPath.row == 1 && [_myFarmName length] > 0) {
        cell.detailTextLabel.text = _myFarmName;
    } else if (indexPath.row == 3) {
        cell.detailTextLabel.text =_brushColorName;
        cell.detailTextLabel.textColor = [UIColor colorWithHex:_brushColor];
    }
    
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
