//
//  SetBrushColorVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/3.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "SetBrushColorVC.h"
#import "LineView.h"
#import "SaveSimpleDataManager.h"

@interface SetBrushColorVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView           *colorTableView;
@property (nonatomic, strong) NSArray               *colors;
@property (nonatomic, assign) NSInteger            selRow;
@end

@implementation SetBrushColorVC

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"BrushColor",nil)];
    [self configColors];
    [self layoutColorTableView];
}

- (void)configColors {
    _colors = @[@{@"name":@"red",@"color":@0xF3704B},
                   @{@"name":@"blue",@"color":@0x009AD6},
                   @{@"name":@"green",@"color":@0x339900},
                   @{@"name":@"yellow",@"color":@0xFFD400},
                   @{@"name":@"gray",@"color":@0x8A8C8E},
                   @{@"name":@"black",@"color":@0x000000}];
    
    _selRow = 0;
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    NSNumber *color = [manager objectForKey:kBruchColorUserdefaultKey];
    if (color != nil) {
        for (NSInteger i = 0; i < [_colors count]; i ++){
            NSDictionary *item = _colors[i];
            if ([item[@"color"] integerValue] == [color integerValue]) {
                _selRow = i;
                break;
            }
        }
    }
}

- (void)layoutColorTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self setColorTableView:tableView];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:0];
}

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _colorTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_colorTableView setTableHeaderView:view];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
    [_colorTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _colorTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_colorTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_colors count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger oldRow = _selRow;
    _selRow  = indexPath.row;
    [tableView reloadRowsAtIndexPaths:
     @[indexPath,[NSIndexPath indexPathForRow:oldRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    //保存配置
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    [manager setObject:[_colors[_selRow] objectForKey:@"color"] forKey:kBruchColorUserdefaultKey];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"colorsTableCell";
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
    
    NSDictionary *config = [_colors objectAtIndex:indexPath.row];
    cell.textLabel.text = config[@"name"];
    cell.imageView.image = [UIImage imageFromColor:[UIColor colorWithHex:[config[@"color"] integerValue]] size:CGSizeMake(20, 20)];
    
    NSString *icon = @"radio-off";
    if (_selRow == indexPath.row) {
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

@end
