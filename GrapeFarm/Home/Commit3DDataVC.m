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

@interface Commit3DDataVC ()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;//定位服务
@property (nonatomic,strong) CLLocation *currentLocation;
@end

@implementation Commit3DDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"ModelData", nil)];
    [self initLocation];
    [self getLocation];
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
        NSString *param = [NSString stringWithFormat:@"{\"longitude\":%f,\"latitude\":%f}",coordinate.longitude,coordinate.latitude];
    });
    
    
    [manager stopUpdatingLocation];
}


@end
