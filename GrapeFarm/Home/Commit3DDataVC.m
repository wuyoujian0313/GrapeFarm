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
#import "CommitBean.h"
#import "NetworkTask.h"
#import "AILoadingView.h"
#import "SaveSimpleDataManager.h"
#import "JHColumnChart.h"
#import "AICircle.h"


@interface Commit3DDataVC ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,FarmSelectIndexDelegate,GrapeVarietiesSelectIndexDelegate,NetworkTaskDelegate>
@property (nonatomic,strong)CLLocationManager  *locationManager;//定位服务
@property (nonatomic,strong)CLLocation         *currentLocation;
@property (nonatomic,strong)UITableView        *contentTableView;
@property (nonatomic,strong)UITextField        *farmTextField;
@property (nonatomic,strong)UITextField        *varietyTextField;
@property (nonatomic,strong)UITextField        *locationTextField;
@property (nonatomic,strong)UIButton           *nextBtn;
@property (nonatomic,strong)JHColumnChart      *chartView;
@end

@implementation Commit3DDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ModelData", nil)];
//    [self initLocation];
//    //
//    __weak typeof(self) wSelf = self;
//    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        typeof(self) sSelf = wSelf;
//        [sSelf getLocation];
//    });
    
    [self layoutNextView];
    [self layoutContentTableView];
    
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    NSDictionary *GPSDic = [manager objectForKey:kPhotoLocationUserdefaultKey];
    if (GPSDic !=nil && [GPSDic count] > 0) {
        NSString *param = [NSString stringWithFormat:@"Lng:%@, Lat:%@",GPSDic[@"Longitude"],GPSDic[@"Latitude"]];
        _locationTextField.text = param;
    }
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
    if (_farmTextField.text == nil || [_farmTextField.text length] <= 0) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"SelectFarm", nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
        [_farmTextField becomeFirstResponder];
        return;
    }
    
    if (_varietyTextField.text == nil || [_varietyTextField.text length] <= 0) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"SelectVariey", nil) duration:1.0 positionY:self.view.frame.size.height/2.0 finishBlock:nil];
        [_farmTextField becomeFirstResponder];
        return;
    }
    
    CLLocationCoordinate2D coordinate = _currentLocation.coordinate;
    NSDictionary *params = @{@"farmName":_farmTextField.text,
                            @"grapeName":_varietyTextField.text,
                            @"latitude": [NSNumber numberWithFloat:coordinate.latitude],
                            @"longitude":[NSNumber numberWithFloat:coordinate.longitude],
                            @"modelData":_modelString,
                            };
    
    [AILoadingView show:NSLocalizedString(@"Loading", nil)];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:kAPICommit
                                             forParam:params
                                             delegate:self
                                            resultObj:[[CommitBean alloc] init]
                                           customInfo:@"commit"];
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

- (void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line1];
    [_contentTableView setTableHeaderView:view];
}

- (void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, _contentTableView.frame.size.width - 20, height)];
    
    NSInteger columCount = 5;
    NSInteger step = (_max_r - _mix_r)%columCount == 0?(_max_r - _mix_r)/columCount:(_max_r - _mix_r)/columCount+1;
    NSMutableArray *valueArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *textArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *stepArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSInteger temp = _mix_r;
    for (NSUInteger i = 0; i < columCount; i++) {
        
        [valueArr addObject:[NSArray arrayWithObject:[NSNumber numberWithInteger:0]]];
        [textArr addObject:[NSString stringWithFormat:@"%ld",(long)temp]];
        [stepArr addObject:[NSNumber numberWithInteger:temp]];
        temp += step;
    }
    for (NSUInteger i = 0; i < [_circles count]; i++) {
        AICircle *circle = _circles[i];
        NSInteger r = [circle.r integerValue];
        for (NSUInteger j = 0; j< [stepArr count]; j++) {
            if (r>=[stepArr[j] integerValue] && r < [stepArr[j] integerValue]+step) {
                valueArr[j] = [NSArray arrayWithObject:[NSNumber numberWithInteger:[valueArr[j][0] integerValue] +1]];
            }
        }
    }

    UILabel *chartLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.width, 25)];
    [chartLabel setFont:[UIFont systemFontOfSize:13]];
    [chartLabel setTextAlignment:NSTextAlignmentRight];
    NSString *desc =[NSString stringWithFormat:NSLocalizedString(@"chartDesc", nil),_max_r,[_circles count]];
    
    NSString *noteString1= [NSString stringWithFormat:@"%lu",(unsigned long)_max_r];
    NSString *noteString2= [NSString stringWithFormat:@"%lu",(unsigned long)[_circles count]];;
    NSRange range1 = [desc rangeOfString:noteString1];
    NSRange range2 = [desc rangeOfString:noteString2];
    NSDictionary *attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor colorWithHex:kTextGrayColor]};
    NSDictionary *attributes2 = @{ NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor colorWithHex:0xF3704B]};
    
    NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:desc];
    [attrStr1 addAttributes:attributes1 range:NSMakeRange(0, desc.length)];
    [attrStr1 addAttributes:attributes2 range:range1];
    [attrStr1 addAttributes:attributes2 range:range2];
    [chartLabel setAttributedText:attrStr1];
    [view addSubview:chartLabel];
    
    JHColumnChart *column = [[JHColumnChart alloc] initWithFrame:CGRectMake(0, chartLabel.bottom, view.width, view.height - 10-chartLabel.bottom)];
    column.valueArr = valueArr;
    column.xShowInfoText = textArr;
    
    column.originSize = CGPointMake(20, 20);
    column.drawFromOriginX = 0;
    column.columnWidth = 30;
    column.typeSpace = (column.width - column.columnWidth *(column.valueArr.count) - column.originSize.x - column.drawFromOriginX)/(column.valueArr.count+1);
    column.isShowYLine = YES;
    column.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    column.bgVewBackgoundColor = [UIColor clearColor];
    column.drawTextColorForX_Y = [UIColor darkGrayColor];
    column.colorForXYLine = [UIColor darkGrayColor];
    column.columnBGcolorsArr = @[@[[UIColor darkGrayColor]]];
    
    [column showAnimation];
    [view addSubview:column];
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
    
    __weak typeof(self ) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *param = [NSString stringWithFormat:@"Lng:%f, Lat:%f",coordinate.longitude,coordinate.latitude];
        typeof(self) sSelf = wSelf;
        sSelf.locationTextField.text = param;
    });
    
    [manager stopUpdatingLocation];
}

#pragma mark - FarmSelectIndexDelegate
- (void)didSelectedFarmName:(NSString *)farmName {
    _farmTextField.text = farmName;
}


#pragma mark - GrapeVarietiesSelectIndexDelegate
- (void)didSelectedGrapeVariety:(NSString *)variety {
    _varietyTextField.text = variety;
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
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 60, 45)];
            self.farmTextField = textField;
            [textField setDelegate:self];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
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
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11,0, tableView.frame.size.width - 60, 45)];
            self.varietyTextField = textField;
            [textField setDelegate:self];
            [textField setTextColor:[UIColor blackColor]];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
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
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11,0, tableView.frame.size.width - 60, 45)];
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
        vc.delegate = self;
        [vc setFarmName:_farmTextField.text saveToConfig:NO];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        //
        GrapeVarietiesVC *vc = [[GrapeVarietiesVC alloc] init];
        vc.delegate = self;
        [vc setGrapeVariety:_varietyTextField.text];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

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

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [AILoadingView dismiss];
    if ([customInfo isEqualToString:@"commit"]) {
        [FadePromptView showPromptStatus:NSLocalizedString(@"CommitSuccess", nil) duration:2.0 finishBlock:^{
            //
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [AILoadingView dismiss];
    [FadePromptView showPromptStatus:NSLocalizedString(@"CommitFailed", nil) duration:2.0 finishBlock:^{
        //
    }];
}


@end
