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

@interface SCN3DModelVC ()<SCNSceneRendererDelegate>
@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNView  *scnView;
@property(nonatomic,strong)UIButton *nextBtn;
@end

@implementation SCN3DModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:NSLocalizedString(@"3DModel", nil)];
    
    self.scnView = [[SCNView alloc] initWithFrame:self.view.bounds];
    [_scnView setBackgroundColor:[UIColor blackColor]];
    [_scnView setAutoenablesDefaultLighting:YES];
    [self.view addSubview:_scnView];

    SCNScene *scene = [[SCNScene alloc] init];
    _scnView.scene = scene;

    SCNCamera *camera = [SCNCamera camera];
    camera.zFar = 200;
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 0, 30);

    [_scnView.scene.rootNode addChildNode:cameraNode];
    
    SCNGeometry *geometer = [SCNGeometry geometry];
    geometer = [SCNSphere sphereWithRadius:2];
    
    UIImage *image = [UIImage imageNamed:@"earth.jpg"];
    UIColor *purpleColor = [UIColor purpleColor];
    geometer.firstMaterial.diffuse.contents = image;
    geometer.firstMaterial.multiply.contents = image;
    geometer.firstMaterial.multiply.intensity = 0.5;
    
    SCNNode *geometerNode = [SCNNode nodeWithGeometry:geometer];
    geometerNode.position = SCNVector3Make(0, 0, 0);
    SCNAction *rotaeAction = [SCNAction rotateByAngle:1 aroundAxis:SCNVector3Make(0, 1, 0) duration:1];
    SCNAction *reRotateAction = [SCNAction repeatActionForever:rotaeAction];
    [geometerNode runAction:reRotateAction];
    [scene.rootNode addChildNode:geometerNode];
    
    [self layoutNextView];
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
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SCNSceneRendererDelegate

/// 维度渲染一次就调用一次
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
}


@end
