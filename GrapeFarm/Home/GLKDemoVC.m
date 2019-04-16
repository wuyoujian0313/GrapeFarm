//
//  GLKDemoVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/15.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "GLKDemoVC.h"

#define kCubeScale            0.4
#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

const GLshort cubeVertices[6][20] = {
    { 1,-1, 1, 1, 0,   -1,-1, 1, 1, 1,   1, 1, 1, 0, 0,  -1, 1, 1, 0, 1 },
    { 1, 1, 1, 1, 0,    1,-1, 1, 1, 1,   1, 1,-1, 0, 0,   1,-1,-1, 0, 1 },
    {-1, 1,-1, 1, 0,   -1,-1,-1, 1, 1,  -1, 1, 1, 0, 0,  -1,-1, 1, 0, 1 },
    { 1, 1, 1, 1, 0,   -1, 1, 1, 1, 1,   1, 1,-1, 0, 0,  -1, 1,-1, 0, 1 },
    { 1,-1,-1, 1, 0,   -1,-1,-1, 1, 1,   1, 1,-1, 0, 0,  -1, 1,-1, 0, 1 },
    { 1,-1, 1, 1, 0,   -1,-1, 1, 1, 1,   1,-1,-1, 0, 0,  -1,-1,-1, 0, 1 },
};

const GLushort cubeColors[6][4] = {
    {1, 0, 0, 1}, {0, 1, 0, 1}, {0, 0, 1, 1}, {1, 1, 0, 1}, {0, 1, 1, 1}, {1, 0, 1, 1},
};

@interface CubeBaseEffect : NSObject
@property (nonatomic, strong) GLKBaseEffect *effect; // 效果类，灯光和材料模式效果
@property (nonatomic, assign) GLuint vertexArray;    // GLuint基础类型
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint normalBuffer;
@end

@implementation CubeBaseEffect

+ (NSMutableArray *)makeCube{
    NSMutableArray *cubeArr = [[NSMutableArray alloc] init];
    for (int f = 0; f < 6; f++) {
        CubeBaseEffect *cube = [[CubeBaseEffect alloc] init];
        GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
        effect.texture2d0.enabled = GL_TRUE;
        effect.useConstantColor = GL_TRUE;
        effect.constantColor =  GLKVector4Make(cubeColors[f][0], cubeColors[f][1], cubeColors[f][2], cubeColors[f][3]);
        
        GLuint vertexArray, vertexBuffer;
        
        glGenVertexArraysOES(1, &vertexArray);
        glBindVertexArrayOES(vertexArray);
        
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices[f]), cubeVertices[f], GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_SHORT, GL_FALSE, 10, BUFFER_OFFSET(0));
        
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_SHORT, GL_FALSE, 10, BUFFER_OFFSET(6));
        
        glBindVertexArrayOES(0);
        
        cube.effect = effect;
        cube.vertexArray = vertexArray;
        cube.vertexBuffer = vertexBuffer;
        cube.normalBuffer = 0;
        
        [cubeArr addObject:cube];
    }
    
    return cubeArr;
}

@end

@interface GLKDemoVC () {
    GLfloat cubePos[3];
    GLfloat cubeRot;
    GLuint cubeTexture;
    GLuint mode;
}
@property(nonatomic,strong)EAGLContext *context;
@property(nonatomic,strong)NSMutableArray<CubeBaseEffect*> *cubeEffects;
@end


@implementation GLKDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBackButton];
    [self setNavTitle:NSLocalizedString(@"3DModel", nil)];
    _cubeEffects = [[NSMutableArray alloc] init];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 创建环境失败，或者将当前线程环境设置失败
    if (!_context || ![EAGLContext setCurrentContext:_context]) {
        return;
    }
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    mode = 1;
    glEnable(GL_DEPTH_TEST);
    _cubeEffects = [CubeBaseEffect makeCube];
    [self setUpCubeEffect];
}

// 设置正方体上的图片效果
- (void)setUpCubeEffect{
    UIImage *image = [UIImage imageNamed:@"speaker"];
    GLKTextureLoader *textureloader = [[GLKTextureLoader alloc] initWithSharegroup:_context.sharegroup];
    __weak typeof(self) wSelf = self;
    [textureloader textureWithCGImage:image.CGImage options:nil queue:nil completionHandler:^(GLKTextureInfo *textureInfo, NSError *error) {
        typeof(self) sSelf = wSelf;
        if(error) {
            NSLog(@"Error loading texture %@",error);
        }
        else {
            for (int f=0; f<6; f++) {
               sSelf.cubeEffects[f].effect.texture2d0.name = textureInfo.name;
            }
        }
    }];
}

#pragma mark - 重绘
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0, 0, 0, 1.0);
    glClearDepthf(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat aspectRatio = (GLfloat)(view.drawableWidth) / (GLfloat)(view.drawableHeight);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f/aspectRatio, 1.0f/aspectRatio, -10.0f, 10.0f);
    projectionMatrix = GLKMatrix4Rotate(projectionMatrix, DegreesToRadians(-30.0f), 0.0f, 1.0f, 0.0f);
    for (int f=0; f<6; f++) {
        _cubeEffects[f].effect.transform.projectionMatrix = projectionMatrix;
    }
    [self drawCube];
}

- (void)drawCube {
    cubeRot += 3;
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(cubePos[0], cubePos[1], cubePos[2]);
    modelView = GLKMatrix4Scale(modelView, kCubeScale, kCubeScale, kCubeScale);
    
    if (mode <= 2)
        modelView = GLKMatrix4Translate(modelView, 1.0f, 0.0f, 0.0f);
    else
        modelView = GLKMatrix4Translate(modelView, 4.5f, 0.0f, 0.0f);
    
    modelView = GLKMatrix4Rotate(modelView, DegreesToRadians(cubeRot), 1, 0, 0);
    modelView = GLKMatrix4Rotate(modelView, DegreesToRadians(cubeRot), 0, 1, 1);
    
    for (int f=0; f<6; f++) {
        _cubeEffects[f].effect.transform.modelviewMatrix = modelView;
        glBindVertexArrayOES(_cubeEffects[f].vertexArray);
        [_cubeEffects[f].effect prepareToDraw];
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

// 默认不支持旋转
-(BOOL)shouldAutorotate {
    return NO;
}

//默认支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)popBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavTitle:(NSString*)title {
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.backgroundColor=[UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    label.text=title;
    label.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    self.title = title;
}

- (UIBarButtonItem*)configBackButton {
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];
    
    self.navigationItem.leftBarButtonItem = itemBtn;
    return itemBtn;
}

@end
