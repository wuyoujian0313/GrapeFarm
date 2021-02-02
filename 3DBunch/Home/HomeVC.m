//
//  HomeVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/25.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "HomeVC.h"
#import "SettingsVC.h"
#import "ColorSegmentVC.h"
#import "DeviceInfo.h"
#import "LineView.h"
#import "AICroppableView.h"
#import "UIView+SizeUtility.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SaveSimpleDataManager.h"
#import "FileCache.h"
#import "AILoadingView.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FadePromptView.h"
#import <Photos/Photos.h>
#import "GoodListVC.h"
#import "NetworkTask.h"
#import "VIPStatusBean.h"


@interface HomeVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,NetworkTaskDelegate>
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)AICroppableView *croppingView;
@property (nonatomic,strong)UIView *toolView;
@property (nonatomic,strong)CLLocationManager  *locationManager;//定位服务
@property (nonatomic,strong)UIImage* image;//当前照片

@end

@implementation HomeVC


- (void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:NSLocalizedString(@"AppName",nil)];
    [self layoutNavView];
    [self layoutToolsView];
    [self layoutImageAreaView];
//    [self relayoutImageView:[UIImage imageNamed:@"instance"]];
    [self relayoutImageView:[UIImage imageNamed:@"obj.jpg"]];
}

- (void)requestVIPStatus {
    [[NetworkTask sharedNetworkTask] startGETTaskApi:kAPIVIPStatus
                                            forParam:nil
                                            delegate:self
                                           resultObj:[[VIPStatusBean alloc] init]
                                          customInfo:@"vipstatus"];
}


- (void)layoutImageAreaView {
    NSInteger imageViewSize = self.view.width - 20;
    NSInteger areaHeight = 30 + 10 + imageViewSize;
    NSInteger top = ((_toolView.top - [DeviceInfo navigationBarHeight]) - areaHeight)/2.0;
    
    UIView *areaView = [[UIView alloc] initWithFrame:CGRectMake(0,top + [DeviceInfo navigationBarHeight], self.view.width, areaHeight)];
    [self.view addSubview:areaView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, areaView.width, 30)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label setText:NSLocalizedString(@"SelectImageArea", nil)];
    [areaView addSubview:label];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, label.bottom + 10, imageViewSize, imageViewSize)];
    [_imageView.layer setCornerRadius:10];
    [_imageView setClipsToBounds:YES];
    [areaView addSubview:_imageView];

    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    NSNumber *color = [manager objectForKey:kBrushColorUserdefaultKey];
    _croppingView = [[AICroppableView alloc] initWithFrame:_imageView.frame];
    if (color !=nil) {
        [_croppingView setLineColor:[UIColor colorWithHex:[color integerValue]]];
    } else {
        [_croppingView setLineColor:[UIColor colorWithHex:0xF3704B]];
    }
    [areaView addSubview:_croppingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(brushColorChange:)
                                                 name:kBrushColorChangeNotification
                                               object:nil];
}

-(void)brushColorChange:(NSNotification *)note{
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    NSNumber *color = [manager objectForKey:kBrushColorUserdefaultKey];
    [_croppingView setLineColor:[UIColor colorWithHex:[color integerValue]]];
    [_croppingView setNeedsDisplay];
}

- (void)layoutNavView {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(toSettingPage)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)layoutToolsView {
    NSInteger buttonWidth = 60;
    NSInteger xfooter = 15 + buttonWidth;
    if ([DeviceInfo detectModel] == MODEL_IPHONE_X) {
        xfooter += 34;
    }
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - xfooter, self.view.frame.size.width, buttonWidth)];
    _toolView = toolView;
    [self.view addSubview:toolView];
    
    NSInteger space = (self.view.frame.size.width - 4*buttonWidth)/5.0;
    for (NSInteger i = 0; i < 4; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(space*(i+1) + i*buttonWidth, 0, buttonWidth, buttonWidth)];
        [button setTag:i + 10];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld",(long)i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld-on",(long)i]] forState:UIControlStateHighlighted];
        [button.layer setBorderColor:[UIColor colorWithHex:kTextGrayColor].CGColor];
        [button.layer setBorderWidth:kLineHeight1px];
        [button.layer setCornerRadius:buttonWidth/2.0];
        [button setClipsToBounds:YES];
        [button addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:button];
        
        if (i == 1) {
            LineView *line = [[LineView alloc] initWithFrame:CGRectMake(button.right + space /2.0, buttonWidth/4.0, kLineHeight1px, buttonWidth/2.0)];
            [line setLineColor:[UIColor grayColor]];
            [toolView addSubview:line];
        }
    }
}

- (void)toolAction:(UIButton *)sender {
    NSInteger type = sender.tag - 10;
    if (type == 0) {
        //拍照
        [self pickerCameraController];
    } else if (type == 1) {
        //相册
        [self pickerImageController];
    } else if (type == 2) {
        //重置
        [_croppingView cleaningBrush];
    } else if (type == 3) {
//        [self requestVIPStatus];
        [self showActionSheet];
    }
}

- (void)showActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) wSelf = self;
    UIAlertAction *purpleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"purple", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
        //
        typeof(self) sSelf = wSelf;
        [sSelf toColorIndex:@0];
    }];
    UIAlertAction *greenAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"green", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
        //
        typeof(self) sSelf = wSelf;
        [sSelf toColorIndex:@1];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:purpleAction];
    [alertController addAction:greenAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)toColorIndex:(NSNumber *)colorIndex  {
    SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
    [manager setObject:colorIndex forKey:kGrapeColorIndexUserdefaultKey];
    if ([colorIndex integerValue] == 0) {
        [self toColorSegmentWithBackgroundColor:[UIColor whiteColor]];
    } else if ([colorIndex integerValue] == 1) {
        [self toColorSegmentWithBackgroundColor:[UIColor blackColor]];
    }
}

- (BOOL)saveImage:(UIImage *)image toFile:(NSString *)filePath {
    if (!image.CGImage) {
        return NO;
    }
    
    @autoreleasepool {
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil);
        if (!destination) {
            return NO;
        }
        
        CGImageDestinationAddImage(destination, image.CGImage, nil);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
    
    return YES;
}

- (void)toSettingPage {
    SettingsVC *vc = [[SettingsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 照片选择
- (void)pickerImageController {
    
    typeof(self) wSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) sSelf = wSelf;
            if (status == PHAuthorizationStatusAuthorized) {
                //允许访问
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing = NO;
                imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                imagePicker.delegate = sSelf;
                imagePicker.navigationBar.barTintColor = [UIColor whiteColor];
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor blackColor],NSForegroundColorAttributeName,
                                      [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
                imagePicker.navigationBar.titleTextAttributes = dict;
                [sSelf presentViewController:imagePicker animated:YES completion:^{}];
            }
            
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                //不允许
                if (@available(iOS 9.0, *)) {
                    UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UnPhotoAlbum",nil) message:NSLocalizedString(@"AllowPhotoAlbum",nil) preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                    }];
                    [controller addAction:confirm];
                    [sSelf presentViewController:controller animated:YES completion:nil];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnPhotoAlbum",nil) message:NSLocalizedString(@"AllowPhotoAlbum",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
                    [alertView show];
                }
            }
        });
        
        
    }];
}

// 拍照
- (void)pickerCameraController  {
    typeof(self) wSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) sSelf = wSelf;
            if (granted) {
                //允许访问
                if ([UIImagePickerController isSourceTypeAvailable:
                     UIImagePickerControllerSourceTypeCamera]) {
                    
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = sSelf;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    if (@available(iOS 11.0, *)) {
                        imagePicker.imageExportPreset = UIImagePickerControllerImageURLExportPresetCurrent;
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    imagePicker.allowsEditing = NO;
                    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIColor blackColor],NSForegroundColorAttributeName,
                                          [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
                    imagePicker.navigationBar.titleTextAttributes = dict;
                    imagePicker.navigationBar.barTintColor = [UIColor whiteColor];
                    [sSelf presentViewController:imagePicker animated:YES completion:^{
                    }];
                }
                
            }else{
                //不允许访问
                if (@available(iOS 9.0, *)) {
                    UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UnCamera",nil) message:NSLocalizedString(@"AllowCamera",nil) preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                    }];
                    [controller addAction:confirm];
                    [sSelf presentViewController:controller animated:YES completion:nil];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnCamera",nil) message:NSLocalizedString(@"AllowCamera",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
                    [alertView show];
                }
                return;
            }
            
        });
    }];
}

///保存图片到本地相册
-(void)imageTopicSave:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
    } else{
        ///图片未能保存到本地
    }
}


#pragma mark - imagepicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = nil;
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        //选择照片
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.image = image;
    
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
        PHAsset *asset = assets.firstObject;
        CLLocation *loction = asset.location;
        NSLog(@"loction:%@",loction);
        
        NSDictionary *GPSDict = @{@"Longitude":[[NSNumber numberWithDouble:loction.coordinate.longitude] stringValue],
                                  @"Latitude":[[NSNumber numberWithDouble:loction.coordinate.latitude] stringValue]
                                  };
        SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
        if(GPSDict != nil && [GPSDict count] > 0) {
            [manager setObject:GPSDict forKey:kPhotoLocationUserdefaultKey];
        } else {
            [manager setObject:[NSDictionary dictionary] forKey:kPhotoLocationUserdefaultKey];
        }


//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library assetForURL:assetURL resultBlock:^(ALAsset *asset)  {
//            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:asset.defaultRepresentation.metadata];
//            //控制台输出查看照片的元数据
//            NSLog(@"%@",infoDic);
//
//            SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
//            NSDictionary *GPSDict= [infoDic  objectForKey:(NSString*)kCGImagePropertyGPSDictionary];
//            if(GPSDict != nil && [GPSDict count] > 0) {
//                [manager setObject:GPSDict forKey:kPhotoLocationUserdefaultKey];
//            } else {
//                [manager setObject:[NSDictionary dictionary] forKey:kPhotoLocationUserdefaultKey];
//            }
//        } failureBlock:^(NSError *error) {
//
//        }];
        
    } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //拍照
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            //
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.image = image;
        [self getLocation];
    }
    
    [self relayoutImageView:image];
    __weak typeof(self) wSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        typeof(self) sSelf = wSelf;
        [sSelf.croppingView cleaningBrush];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
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
    [self initLocation];
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied: {
            //[FadePromptView showPromptStatus:NSLocalizedString(@"RequestLocation", nil) duration:1.5 finishBlock:nil];
            break;
        }

        default:
            break;
    }
}

//- (NSDictionary*)GPSDictionary:(CLLocation *)loction{
//    NSTimeZone*  timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:timeZone];
//    [formatter setDateFormat:@"HH:mm:ss.SS"];
//    CLLocation *location = loction;
//    NSDictionary *gpsDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                               [NSNumber numberWithFloat:location.coordinate.latitude],kCGImagePropertyGPSLatitude,
//                               ((location.coordinate.latitude >= 0) ? @"N" : @"S"), kCGImagePropertyGPSLatitudeRef,
//                               [NSNumber numberWithFloat:location.coordinate.longitude],kCGImagePropertyGPSLongitude,
//                               ((location.coordinate.longitude >= 0) ? @"E" : @"W"), kCGImagePropertyGPSLongitudeRef,
//                               [formatter stringFromDate:[location timestamp]], kCGImagePropertyGPSTimeStamp,
//                               nil];
//    return gpsDict;
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    CLLocation *newLocation = locations.lastObject;
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    //当前的经纬度
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    NSLog(@"当前的经纬度 %f,%f",coordinate.latitude,coordinate.longitude);
    __weak typeof(self ) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(self) sSelf = wSelf;
       [sSelf writeCGImage:sSelf.image location:newLocation];
        
        NSDictionary *GPSDict = @{@"Longitude":[[NSNumber numberWithDouble:newLocation.coordinate.longitude] stringValue],
                                  @"Latitude":[[NSNumber numberWithDouble:newLocation.coordinate.latitude] stringValue]
                                  };
        SaveSimpleDataManager *manager = [[SaveSimpleDataManager alloc] init];
        if(GPSDict != nil && [GPSDict count] > 0) {
            [manager setObject:GPSDict forKey:kPhotoLocationUserdefaultKey];
        } else {
            [manager setObject:[NSDictionary dictionary] forKey:kPhotoLocationUserdefaultKey];
        }
    });
    
    [manager stopUpdatingLocation];
}

/*
 保存图片到相册
 */
- (void)writeCGImage:(UIImage*)image location:(CLLocation *)location {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        // 存储图片
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            newAssetRequest.location = location;
            newAssetRequest.creationDate = [NSDate date];
        } completionHandler:^(BOOL success, NSError *error) {
            
        }];
    } else if (status == PHAuthorizationStatusRestricted){
        //"家长控制,不允许访问"
    } else if (status == PHAuthorizationStatusNotDetermined){
        //"用户还没有做出选择"
    } else if (status == PHAuthorizationStatusDenied){
        //"用户不允许当前应用访问相册"
    }

//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
//        if (error) {
//            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
//        } else {
//            NSLog( @"Wrote image with metadata to Photo Library");
//        }
//    };
//
//    //保存相片到相册 注意:必须使用[image CGImage]不能使用强制转换: (__bridge CGImageRef)image,否则保存照片将会报错
//    [library writeImageToSavedPhotosAlbum:[image CGImage]
//                                 metadata:metadata
//                          completionBlock:imageWriteCompletionBlock];
}

- (void)relayoutImageView:(UIImage *)image {
    if (image != nil) {
        //
        NSInteger imageViewSize = self.view.width - 20;
        if (image.size.width != image.size.height) {
            // 不是正方形的图片
            if (image.size.width >= imageViewSize) {
                
                CGFloat h = image.size.height/image.size.width * imageViewSize;
                if (h >= imageViewSize) {
                    // 以高度为准 = imageViewSize;
                    CGFloat w = image.size.width/image.size.height * imageViewSize;
                    [_imageView setHeight:imageViewSize];
                    [_imageView setWidth:w];
                    [_imageView setLeft:(self.view.width - w)/2.0];
                    
                } else {
                    // 以宽度为准
                    [_imageView setWidth:imageViewSize];
                    [_imageView setLeft:10];
                    [_imageView setHeight:h];
                }
                
            } else {
                // 以高度为准
                if (image.size.height >= imageViewSize) {
                    CGFloat w = image.size.width/image.size.height * imageViewSize;
                    [_imageView setLeft:(imageViewSize-w)/2.0];
                    [_imageView setWidth:w];
                } else {
                    // 以实际为准,
                    [_imageView setLeft:(imageViewSize-image.size.width)/2.0];
                    [_imageView setWidth:image.size.width];
                    [_imageView setHeight:image.size.height];
                }
            }
        } else {
            // 是正方形的图片
            [_imageView setWidth:imageViewSize];
            [_imageView setHeight:imageViewSize];
            [_imageView setLeft:10];
        }
        
        [_croppingView setFrame:_imageView.frame];
        _imageView.image = image;
    }
}


- (void)toColorSegmentWithBackgroundColor:(UIColor *)color {
    [AILoadingView show:NSLocalizedString(@"processing", nil)];
    
    FileCache *fileCache = [FileCache sharedFileCache];
    UIImage *image = self.imageView.image;
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self ) wSelf = self;
    dispatch_async(queue, ^{
        typeof(self ) sSelf = wSelf;
        UIImage *croppedImage = [sSelf.croppingView croppingOfImage:image backgroudColor:color];
        [fileCache writeData:UIImagePNGRepresentation(croppedImage) forKey:kCroppedImageFileKey];
   
#if DEBUG
        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/final.png"];
        [sSelf saveImage:croppedImage toFile:path];
        NSLog(@"cropped image path: %@",path);
#endif
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            // 追加在主线程中执行的任务
            [AILoadingView dismiss];
            ColorSegmentVC *vc = [[ColorSegmentVC alloc] init];
            [sSelf.navigationController pushViewController:vc animated:YES];
        });
    });
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [AILoadingView dismiss];
    if ([customInfo isEqualToString:@"vipstatus"]) {
        VIPStatusBean *bean = (VIPStatusBean *)result;
        NSString *status = bean.status;
        /*
         "'0' 提交次数少于10次的;" +
         "'1' 提交次数大于10次且未购买VIP;" +
         "'2' 提交次数大于10次且购买VIP已到期;" +
         "'3' 提交次数大于10次且购买VIP未到期"
         */
        
        if ([status isEqualToString:@"0"]) {
            [self showActionSheet];
        } else if([status isEqualToString:@"1"]) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"noservice", nil) duration:1.5 finishBlock:^{
                //
                GoodListVC *vc = [[GoodListVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else if([status isEqualToString:@"2"]) {
            [FadePromptView showPromptStatus:NSLocalizedString(@"outofservice", nil) duration:1.5 finishBlock:^{
                //
                GoodListVC *vc = [[GoodListVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else if([status isEqualToString:@"3"]) {
            [self showActionSheet];
        }
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [AILoadingView dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:2.0 finishBlock:^{
        //
    }];
}
@end
