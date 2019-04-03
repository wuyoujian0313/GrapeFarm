//
//  GrapeVarietiesVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "GrapeVarietiesVC.h"
#import "LineView.h"

@interface GrapeVarietiesVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView           *varietiesTableView;
@property (nonatomic, strong) NSArray               *varieties;
@property (nonatomic, copy) NSString                *variety;
@property (nonatomic, assign) NSInteger             selIndex;
@end

@implementation GrapeVarietiesVC

-(void)dealloc {
    
}

- (void)setGrapeVariety:(NSString *)variety {
    _variety = variety;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"Varieties",nil)];
    [self configVarieties];
    [self layoutVarietiesTableView];
}

- (void)configVarieties {
    _varieties = @[@"varietiy1",@"variety2",@"variety3",@"variety4",];
    if (_variety != nil && [_variety length] > 0) {
        for (NSInteger i = 0; i < [_varieties count]; i++) {
            NSString *name = _varieties[i];
            if ([name isEqualToString:_variety]) {
                _selIndex = i;
                break;
            }
        }
    } else {
        _selIndex = 0;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectedGrapeVariety:)]) {
            [_delegate didSelectedGrapeVariety:_varieties[_selIndex]];
        }
    }
}

- (void)layoutVarietiesTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self setVarietiesTableView:tableView];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:0];
}

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _varietiesTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_varietiesTableView setTableHeaderView:view];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
    [_varietiesTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _varietiesTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_varietiesTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_varieties count];
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
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectedGrapeVariety:)]) {
        [_delegate didSelectedGrapeVariety:_varieties[_selIndex]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"varietiesTableCell";
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
    
    cell.textLabel.text = [_varieties objectAtIndex:indexPath.row];
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
@end
