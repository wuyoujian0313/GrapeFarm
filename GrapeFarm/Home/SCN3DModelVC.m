//
//  SCN3DModelVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/5/17.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "SCN3DModelVC.h"
#import <SceneKit/SceneKit.h>
#import "DeviceInfo.h"
#import "Commit3DDataVC.h"
#import "UIView+SizeUtility.h"
#import "AICircle.h"
#import "FileCache.h"


@interface SCN3DModelVC ()<SCNSceneRendererDelegate>
@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNView  *scnView;
@property (nonatomic, strong) UIButton *nextBtn;
@property(nonatomic,strong)NSArray<AICircle*> *circles;
@end

@implementation SCN3DModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setNavTitle:NSLocalizedString(@"3DModel", nil)];
    [self layoutNextView];
    [self drawSpheres];
}

- (void)setCircleEdges:(NSArray *)circles{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    FileCache *fileCache = [FileCache sharedFileCache];
    NSData *imageData = [fileCache dataFromCacheForKey:kCroppedImageFileKey];
    UIImage *image = [UIImage imageWithData:imageData];
    for (AICircle *circle in circles) {
        CGFloat x = [circle.x floatValue] - image.size.width/2.0;
        CGFloat y = image.size.height/2.0 - [circle.y floatValue] ;
        
        AICircle *c = [[AICircle alloc] init];
        c.x = [NSNumber numberWithFloat:x];
        c.y = [NSNumber numberWithFloat:y];
        c.r = [NSNumber numberWithFloat:[circle.r floatValue]];
        
        [arr addObject:c];
    }
    
    self.circles = arr;
}

- (void)drawSpheres {
    self.scnView = [[SCNView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, _nextBtn.top - 10 - [DeviceInfo navigationBarHeight])];
    [_scnView setBackgroundColor:[UIColor blackColor]];
    // 允许相机控制
    [_scnView setAllowsCameraControl:YES];
    [_scnView setAutoenablesDefaultLighting:YES];
    [self.view addSubview:_scnView];
    //创建场景
    SCNScene *scene = [[SCNScene alloc] init];
    _scnView.scene = scene;
    
    CGFloat max_x = 0;//_scnView.width/2.0;
    CGFloat max_y = 0;//_scnView.height/2.0;
//    CGFloat scale = _scnView.height/_scnView.width;
    CGFloat max_r = 0;
    
    // 获取最大的x和y坐标值
    for (AICircle *circle in _circles) {
        if ([circle.x floatValue] > max_x) {
            max_x = [circle.x floatValue];
        }
        
        if ([circle.y floatValue] > max_y) {
            max_y = [circle.y floatValue];
        }
        
        if ([circle.r floatValue] > max_r) {
            max_r = [circle.r floatValue];
        }
    }

    //创建camera，camera也是作为一个节点在场景中
    SCNCamera *camera = [SCNCamera camera];
    camera.automaticallyAdjustsZRange = YES;
    if (@available(iOS 11.0, *)) {
        camera.fieldOfView = 90;
    } else {
        // Fallback on earlier versions
        camera.xFov = 90;
        camera.yFov = 90;
    }

    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    CGFloat max = MAX(max_x, max_y);
    CGFloat camera_d = 1.5*(max_r+max); //scale*(max_r + 2*max);
    cameraNode.position = SCNVector3Make(0,0, camera_d);
    [_scnView.scene.rootNode addChildNode:cameraNode];
    
    SCNLight *light = [SCNLight light]; // 创建灯光
    light.type = SCNLightTypeOmni; // 设置灯光类型
    light.color = [UIColor colorWithHex:0x350a6d]; // 设置灯光颜色
    
    SCNNode *lightNode = [SCNNode node];
    lightNode.light  = light;
    lightNode.position = SCNVector3Make(0,0, camera_d);
    [_scnView.scene.rootNode addChildNode:lightNode];
    //把所有的圆作为一组
    SCNNode *groupNode = [SCNNode node];
    groupNode.position = SCNVector3Make(0, 0, 0);
    
    //组节点围绕y轴转动
    SCNAction *rotaeAction = [SCNAction rotateByAngle:-1 aroundAxis:SCNVector3Make(0, 1, 0) duration:1];
    SCNAction *reRotateAction = [SCNAction repeatActionForever:rotaeAction];
    [groupNode runAction:reRotateAction];
    
    UIColor *color = [UIColor whiteColor];
    for (NSInteger i = 0; i < [_circles count]; i++) {
        CGFloat x = [_circles[i].x floatValue];
        CGFloat y = [_circles[i].y floatValue];
        CGFloat r = [_circles[i].r floatValue];
        SCNGeometry *geometer = [SCNGeometry geometry];
        geometer = [SCNSphere sphereWithRadius:r];
        geometer.firstMaterial.diffuse.contents = color;
        geometer.firstMaterial.multiply.contents = color;
        geometer.firstMaterial.specular.contents = [UIColor whiteColor];
        geometer.firstMaterial.shininess = .8;
        geometer.firstMaterial.lightingModelName = SCNLightingModelBlinn;
        
        SCNNode *geometerNode = [SCNNode nodeWithGeometry:geometer];
        geometerNode.position = SCNVector3Make(x, y, 0);
        [groupNode addChildNode:geometerNode];
    }

    [_scnView.scene.rootNode addChildNode:groupNode];
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
    [nextBtn setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [nextBtn setFrame:CGRectMake(11, self.view.frame.size.height - xfooter, self.view.frame.size.width - 22, buttonHeight)];
    [nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)nextAction:(UIButton *)sender {
    Commit3DDataVC *vc = [[Commit3DDataVC alloc] init];
    NSString *modelString = @"";
    for (AICircle *circle in _circles) {
        modelString = [modelString stringByAppendingFormat:@"%.2f,%.2f,%.2f\n",[circle.x floatValue],[circle.y floatValue],[circle.r floatValue]];
    }

    vc.modelString = modelString;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SCNSceneRendererDelegate

/// 维度渲染一次就调用一次
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
}


@end
