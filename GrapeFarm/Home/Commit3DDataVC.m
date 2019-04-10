//
//  Commit3DDataVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/28.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "Commit3DDataVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FadePromptView.h"
#import "LineView.h"
#import "FarmListVC.h"
#import "GrapeVarietiesVC.h"
#import "DeviceInfo.h"
#import "UIView+SizeUtility.h"

@interface Commit3DDataVC ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic,strong)CLLocationManager  *locationManager;//定位服务
@property (nonatomic,strong)CLLocation         *currentLocation;
@property (nonatomic,strong)UITableView        *contentTableView;
@property (nonatomic,strong)UITextField        *farmTextField;
@property (nonatomic,strong)UITextField        *varietyTextField;
@property (nonatomic,strong)UITextField        *locationTextField;
@property (nonatomic,strong)UIButton           *nextBtn;
@property (nonatomic,strong)UITextView         *textView;
@end

@implementation Commit3DDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ModelData", nil)];
    [self initLocation];
    [self getLocation];
    [self layoutNextView];
    [self layoutContentTableView];
}

- (void)layoutNextView {
    NSInteger buttonHeight = 45;
    NSInteger xfooter = 15 + buttonHeight;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn = nextBtn;
    [nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kButtonTapColor]] forState:UIControlStateHighlighted];
    [nextBtn.layer setBorderColor:[UIColor colorWithHex:kBoundaryColor].CGColor];
    [nextBtn.layer setBorderWidth:kLineHeight1px];
    [nextBtn.layer setCornerRadius:kButtonCornerRadius];
    [nextBtn setClipsToBounds:YES];
    [nextBtn setTitle:NSLocalizedString(@"Commit",nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [nextBtn setFrame:CGRectMake(11, self.view.frame.size.height - xfooter, self.view.frame.size.width - 22, buttonHeight)];
    [nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)nextAction:(UIButton *)sender {
    //
}

- (void)layoutContentTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, _nextBtn.top - [DeviceInfo navigationBarHeight]) style:UITableViewStylePlain];
    [self setContentTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBounces:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:10];
    [self setTableViewFooterView:tableView.height - 10 - 3*45];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line1];
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
    [_textView setText:@"Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest Nest "];
    [view addSubview:_textView];
    
    [_contentTableView setTableFooterView:view];
}

- (void)initLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 100.0f;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0){
            [_locationManager requestWhenInUseAuthorization];
            if (@available(iOS 9.0, *)) {
                _locationManager.allowsBackgroundLocationUpdates = YES;
            } else {
                // Fallback on earlier versions
            }
        }
    } else {
        [FadePromptView showPromptStatus:NSLocalizedString(@"noGPS", nil) duration:1.5 finishBlock:nil];
    }
}

- (void)getLocation {
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied: {
            [FadePromptView showPromptStatus:NSLocalizedString(@"RequestLocation", nil) duration:1.5 finishBlock:nil];
            break;
        }
            
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *newLocation = locations.lastObject;
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 2.0) return;
    if (newLocation.horizontalAccuracy < 0) return;
    
    _currentLocation = newLocation;
    
    //当前的经纬度
    CLLocationCoordinate2D coordinate = _currentLocation.coordinate;
    NSLog(@"当前的经纬度 %f,%f",coordinate.latitude,coordinate.longitude);
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *param = [NSString stringWithFormat:@"{\"longitude\":%f,\"latitude\":%f}",coordinate.longitude,coordinate.latitude];
    });
    
    
    [manager stopUpdatingLocation];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 不使用重用机制
    NSInteger row = [indexPath row];
    NSInteger curRow = 0;
    
    if (row == curRow) {
        static NSString *reusedCellID = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 40, 45)];
            self.farmTextField = textField;
            [textField setDelegate:self];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setClearsOnBeginEditing:YES];
            [textField setPlaceholder:NSLocalizedString(@"SelectFarm",nil)];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11,0, tableView.frame.size.width - 40, 45)];
            self.varietyTextField = textField;
            [textField setDelegate:self];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setClearsOnBeginEditing:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
            [textField setPlaceholder:NSLocalizedString(@"SelectVariey",nil)];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"Cell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11,0, tableView.frame.size.width - 40, 45)];
            self.locationTextField = textField;
            [textField setDelegate:self];
            [textField setEnabled:NO];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:NSLocalizedString(@"GetLocation",nil)];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            cell.accessoryView = imageView;
            [(UIImageView*)cell.accessoryView setImage:[UIImage imageNamed:@"address"]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //
        FarmListVC *vc = [[FarmListVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        //
        GrapeVarietiesVC *vc = [[GrapeVarietiesVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 1.0;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 1.0;
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField  {
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _farmTextField) {
        [_varietyTextField becomeFirstResponder];
    } else if (textField == _varietyTextField){
        [textField resignFirstResponder];
    }
    
    return YES;
}


@end
