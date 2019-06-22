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
@property (nonatomic, strong) NSArray<AICircle*> *circles;
@property (nonatomic, assign) NSInteger max_r;
@property (nonatomic, assign) NSInteger mix_r;
@property (nonatomic, strong) SCNNode *groupNode;
@property (nonatomic, assign) NSInteger XAngle;
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
        c.z = [NSNumber numberWithInteger:[circle.z integerValue]];
        [arr addObject:c];
    }
    
    self.circles = arr;
}



// 缩放手势
- (void)pinch:(UIPinchGestureRecognizer *)pinchGesture{
    if([pinchGesture numberOfTouches] < 2) {
        return;
    }
    SCNAction *scaleAction = [SCNAction scaleBy:pinchGesture.scale duration:0];
    [_groupNode runAction:scaleAction];
    pinchGesture.scale = 1.0;
}

- (void)rotation:(UIRotationGestureRecognizer *)rotationGesture {
    // 旋转角度
    float rotate = rotationGesture.rotation;
    // 模型平面垂直向量
    SCNVector3 v = SCNVector3Make(0, cos(_XAngle*M_PI/180), sin(_XAngle*M_PI/180));
    // Action
    SCNAction *rotateAction = [SCNAction rotateByAngle:-rotate*0.75 aroundAxis:v duration:0];
    [_groupNode runAction:rotateAction];
    
    rotationGesture.rotation = 0;
}

- (void)panned:(UIPanGestureRecognizer *)panGesture{
    NSInteger TX = 0,TY = 0;
    CGPoint transPoint = [panGesture translationInView:_scnView];
    // 单指
    if ([panGesture numberOfTouches] == 1) {
        TX = transPoint.x * 4 ;
        TY = -transPoint.y * 4 ;
        
        SCNAction *pan = [SCNAction moveByX:TX y:TY z:0 duration:0];
        [_groupNode runAction:pan];
    }
//    // 双指
//    else if ([panGesture numberOfTouches] == 2) {
//        // 偏转角度
//        CGFloat angle = transPoint.y / self.view.width *100;
//        // x轴累计偏转角
//        _XAngle += angle;
//        // 40°~90°阈值
//        if (_XAngle > 90) {
//            _XAngle = 90;
//            angle = 0;
//        } else if (_XAngle < 40) {
//            _XAngle = 40;
//            angle = 0;
//        }
//
//        SCNAction *action = [SCNAction rotateByAngle:(angle*M_PI/180) aroundAxis:SCNVector3Make(1, 0, 0) duration:0];
//        [_groupNode runAction:action];
//    }
    [panGesture setTranslation:CGPointMake(0, 0) inView:_scnView];
}

//// 单击手势
//- (void)tap:(UITapGestureRecognizer *)tapGesture
//{
//    CGPoint tapPoint = [tapGesture locationInView:_scnView];
//    NSArray *arr = [_scnView hitTest:tapPoint options:nil];
//    if (arr.count > 0) {
//        SCNHitTestResult *result = arr[0];
//        NSLog(@"%@", result.node.name);
//    }
//}

- (void)drawSpheres {
    self.scnView = [[SCNView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, _nextBtn.top - 10 - [DeviceInfo navigationBarHeight])];
    [_scnView setDelegate:self];
    [_scnView setBackgroundColor:[UIColor blackColor]];
    // 允许相机控制
//    [_scnView setAllowsCameraControl:YES];
    [_scnView setAutoenablesDefaultLighting:YES];
    [self.view addSubview:_scnView];
    
    // 旋转手势
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
//    rotationGesture.delegate = self;
    [_scnView addGestureRecognizer:rotationGesture];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
//    pinchGesture.delegate = self;
    [_scnView addGestureRecognizer:pinchGesture];
    
    // 平移手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
//    panGesture.delegate = self;
    [_scnView addGestureRecognizer:panGesture];
    
    // 点击手势
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
////    tapGesture.delegate = self;
//    [_scnView addGestureRecognizer:tapGesture];
    
    //创建场景
    SCNScene *scene = [[SCNScene alloc] init];
    _scnView.scene = scene;
    
    CGFloat max_x = 0;//_scnView.width/2.0;
    CGFloat max_y = 0;//_scnView.height/2.0;
//    CGFloat scale = _scnView.height/_scnView.width;
    NSInteger max_r = 0;
    NSInteger mix_r = 0;
    
    // 获取最大的x和y坐标值
    for (AICircle *circle in _circles) {
        if (fabsf([circle.x floatValue] )> max_x) {
            max_x = fabsf([circle.x floatValue]);
        }
        
        if (fabsf([circle.y floatValue]) > max_y) {
            max_y = fabsf([circle.y floatValue]);
        }
        
        if ([circle.r floatValue]> max_r) {
            max_r = [circle.r floatValue];
        }
        
        if ([circle.r integerValue] < mix_r) {
            mix_r = [circle.r integerValue];
        }
    }
    
    _max_r = max_r;
    _mix_r = mix_r;

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
    CGFloat camera_d = 1.2*(max_r+max); //scale*(max_r + 2*max);
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
    self.groupNode = groupNode;
    groupNode.position = SCNVector3Make(0, 0, 0);
    
    //组节点围绕y轴转动
//    SCNAction *rotaeAction = [SCNAction rotateByAngle:-1 aroundAxis:SCNVector3Make(0, 1, 0) duration:1];
//    SCNAction *reRotateAction = [SCNAction repeatActionForever:rotaeAction];
//    [groupNode runAction:reRotateAction];
    
    UIColor *color = [UIColor whiteColor];
    for (NSInteger i = 0; i < [_circles count]; i++) {
        CGFloat x = [_circles[i].x floatValue];
        CGFloat y = [_circles[i].y floatValue];
        CGFloat r = [_circles[i].r floatValue];
        CGFloat z = [_circles[i].z floatValue];
        SCNGeometry *geometer = [SCNGeometry geometry];
        geometer = [SCNSphere sphereWithRadius:r];
        geometer.firstMaterial.diffuse.contents = color;
        geometer.firstMaterial.multiply.contents = color;
        geometer.firstMaterial.specular.contents = [UIColor whiteColor];
        geometer.firstMaterial.shininess = .8;
        geometer.firstMaterial.lightingModelName = SCNLightingModelBlinn;
        
        SCNNode *geometerNode = [SCNNode nodeWithGeometry:geometer];
        geometerNode.position = SCNVector3Make(x, y, z);
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
        modelString = [modelString stringByAppendingFormat:@"%.2f,%.2f,%.lu\n",[circle.x floatValue],[circle.y floatValue],[circle.r integerValue]];
    }

    vc.circles = _circles;
    vc.modelString = modelString;
    vc.mix_r = _mix_r;
    vc.max_r = _max_r;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SCNSceneRendererDelegate

/// 维度渲染一次就调用一次
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
}


@end
