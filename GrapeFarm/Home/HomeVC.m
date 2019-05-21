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



@interface HomeVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)AICroppableView *croppingView;
@property (nonatomic,strong)UIView *toolView;
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
        if ([_croppingView canCropping]) {
            //确定
            UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"setBackgroudColor", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"black_bg", nil),NSLocalizedString(@"white_bg", nil),nil];
            [sheet showInView:self.view];
        } else {
            [self toColorSegmentWithBackgroundColor:nil];
        }
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
    //
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    imagePicker.navigationBar.barTintColor = [UIColor whiteColor];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor blackColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
    imagePicker.navigationBar.titleTextAttributes = dict;
    [self presentViewController:imagePicker animated:YES completion:^{
    }];
}

// 拍照
- (void)pickerCameraController  {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied ) {
        if (@available(iOS 9.0, *)) {
            UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UnCamera",nil) message:NSLocalizedString(@"AllowCamera",nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            }];
            [controller addAction:confirm];
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnCamera",nil) message:NSLocalizedString(@"AllowCamera",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
            [alertView show];
        }
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.allowsEditing = YES;
        imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor blackColor],NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
        imagePicker.navigationBar.titleTextAttributes = dict;
        imagePicker.navigationBar.barTintColor = [UIColor whiteColor];
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
    }
}


#pragma mark - imagepicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = nil;
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        //选择照片
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //拍照
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            //
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }
    }
    
    [self relayoutImageView:image];
    __weak typeof(self) wSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        typeof(self) sSelf = wSelf;
        [sSelf.croppingView cleaningBrush];
    }];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)toColorSegmentWithBackgroundColor:(UIColor *)color {
    FileCache *fileCache = [FileCache sharedFileCache];
    UIImage *croppedImage = [_croppingView croppingOfImage:_imageView.image backgroudColor:color];
    [fileCache writeData:UIImagePNGRepresentation(croppedImage) forKey:kCroppedImageFileKey];
    ColorSegmentVC *vc = [[ColorSegmentVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/final.png"];
    [self saveImage:croppedImage toFile:path];
    NSLog(@"cropped image path: %@",path);
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        UIColor *color  = [UIColor blackColor];
        if (buttonIndex == 1) {
            color = [UIColor whiteColor];
        }
        
        [self toColorSegmentWithBackgroundColor:color];
    }
}


@end
