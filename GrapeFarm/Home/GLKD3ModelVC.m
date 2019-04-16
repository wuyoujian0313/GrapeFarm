//
//  GLKD3ModelVC.m
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/15.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "GLKD3ModelVC.h"
#import "DeviceInfo.h"
#import "Commit3DDataVC.h"

#define kCubeScale            0.4
#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

//顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
/*
 顶点数组里包括顶点坐标，OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
 纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角。
 索引数组是顶点数组的索引，把顶点数组看成4个顶点，每个顶点会有5个GLfloat数据，索引从0开始。
 
 顶点位置用于确定在什么地方显示，法线用于光照模型计算，纹理则用在贴图中。
 世界坐标是OpenGL中用来描述场景的坐标，Z+轴垂直屏幕向外，X+从左到右，Y+轴从下到上，是右手笛卡尔坐标系统。
 我们用这个坐标系来描述物体及光源的位置。
 
 定点的属性：
 typedef NS_ENUM(GLint, GLKVertexAttrib)
 {
    GLKVertexAttribPosition,
    GLKVertexAttribNormal,
    GLKVertexAttribColor,
    GLKVertexAttribTexCoord0,
    GLKVertexAttribTexCoord1
 } NS_ENUM_AVAILABLE(10_8, 5_0);
 
 */
typedef struct {
    GLshort Positon[3];//位置
    GLshort TexCoord[2];//纹理
} Vertex;

const GLshort cubeVertices[6][20] = {
    { 1,-1, 1, 1, 0,   -1,-1, 1, 1, 1,   1, 1, 1, 0, 0,  -1, 1, 1, 0, 1 },// 第1个面
    { 1, 1, 1, 1, 0,    1,-1, 1, 1, 1,   1, 1,-1, 0, 0,   1,-1,-1, 0, 1 },// 第2个面
    {-1, 1,-1, 1, 0,   -1,-1,-1, 1, 1,  -1, 1, 1, 0, 0,  -1,-1, 1, 0, 1 },// 第3个面
    { 1, 1, 1, 1, 0,   -1, 1, 1, 1, 1,   1, 1,-1, 0, 0,  -1, 1,-1, 0, 1 },// 第4个面
    { 1,-1,-1, 1, 0,   -1,-1,-1, 1, 1,   1, 1,-1, 0, 0,  -1, 1,-1, 0, 1 },// 第5个面
    { 1,-1, 1, 1, 0,   -1,-1, 1, 1, 1,   1,-1,-1, 0, 0,  -1,-1,-1, 0, 1 },// 第6个面
};

// 6个面的颜色，颜色值，RGBA
const GLushort cubeColors[6][4] = {
    {1, 0, 0, 1}, {0, 1, 0, 1}, {0, 0, 1, 1}, {1, 1, 0, 1}, {0, 1, 1, 1}, {1, 0, 1, 1},
};

// 自定义的着色器
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
        
        /*
         glGenBuffers申请一个标识符
         glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
         glBufferData把顶点数据从cpu内存复制到gpu内存
         glEnableVertexAttribArray 是开启对应的顶点属性
         glVertexAttribPointer设置合适的格式从buffer里面读取数据
        
         参数“GL_STATIC_DRAW”，它表示此缓冲区内容只能被修改一次，但可以无限次读取。
         */
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices[f]), cubeVertices[f], GL_STATIC_DRAW);
        
        // 位置属性
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_SHORT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(0));
        
        // 纹理属性
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_SHORT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(3*sizeof(GLshort)));
        
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

@interface GLKD3ModelVC ()
@property(nonatomic,assign)GLfloat cubeRot;
@property(nonatomic,strong)EAGLContext *context;
@property(nonatomic,strong)NSMutableArray<CubeBaseEffect*> *cubeEffects;
@property(nonatomic,strong)UIButton *nextBtn;
@end


@implementation GLKD3ModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBackButton];
    [self setNavTitle:NSLocalizedString(@"3DModel", nil)];
    _cubeEffects = [[NSMutableArray alloc] init];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 创建环境失败或者将当前线程环境设置失败
    if (!_context || ![EAGLContext setCurrentContext:_context]) {
        return;
    }
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;
    /*
     OpenGL上下文有一个缓冲区，它用以存储将在屏幕中显示的颜色。
     你可以使用其属性来设置缓冲区中每个像素的颜色格式。
     缺省值是GLKViewDrawableColorFormatRGBA8888，即缓冲区的每个像素的最小组成部分(-个像素有四个元素组成 RGBA)
     使用8个bit(如R使用8个bit)（所以每个像素4个字节 既 4*8 个bit）。
     你可以设置为GLKViewDrawableColorFormatRGB565，从而使你的app消耗更少的资源（内存和处理时间）。

     */
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    /*
     OpenGL上下文还可以（可选地）有另一个缓冲区，称为深度缓冲区。
     这帮助我们确保更接近观察者的对象显示在远一些的对象的前面（意思就是离观察者近一些的对象会挡住在它后面的对象）。
     其缺省的工作方式是：OpenGL把接近观察者的对象的所有像素存储到深度缓冲区，当开始绘制一个像素时，\
     它（OpenGL）首先检查深度缓冲区，看是否已经绘制了更接近观察者的什么东西，
     如果是则忽略它（要绘制的像素，就是说，在绘制一个像素之前，看看前面有没有挡着它的东西，如果有那就不用绘制了）。
     否则，把它增加到深度缓冲区和颜色缓冲区。
     你可以设置这个属性，以选择深度缓冲区的格式。缺省值是GLKViewDrawableDepthFormatNone，意味着完全没有深度缓冲区。
     但是如果你要使用这个属性（一般用于3D游戏），你应该选择GLKViewDrawableDepthFormat16或GLKViewDrawableDepthFormat24。这里的差别是使用GLKViewDrawableDepthFormat16将消耗更少的资源，但是当对象非常接近彼此时，你可能存在渲染问题（）。
     */
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glEnable(GL_DEPTH_TEST);
    _cubeEffects = [CubeBaseEffect makeCube];
    [self setUpCubeEffect];
    [self layoutNextView];
}

// 设置正方体上的图片效果
- (void)setUpCubeEffect{
    //纹理坐标系是相反的
    UIImage *image = [UIImage imageNamed:@"speaker"];
    GLKTextureLoader *textureloader = [[GLKTextureLoader alloc] initWithSharegroup:_context.sharegroup];
    __weak typeof(self) wSelf = self;
    [textureloader textureWithCGImage:image.CGImage options:nil queue:nil completionHandler:^(GLKTextureInfo *textureInfo, NSError *error) {
        typeof(self) sSelf = wSelf;
        if(error) {
            NSLog(@"Error loading texture %@",error);
        } else {
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
    
    /*
     在OpenGL ES里面，图形变换的表现形式就是矩阵操作，GLKit也提供了很多矩阵操作函数
     GLKMatrix4MakePerspective是透视投影变换
     GLKMatrix4Translate是平移变换
     */
    GLfloat aspectRatio = (GLfloat)(view.drawableWidth) / (GLfloat)(view.drawableHeight);
    // 正交变换
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f/aspectRatio, 1.0f/aspectRatio, -10.0f, 10.0f);
    projectionMatrix = GLKMatrix4Rotate(projectionMatrix, DegreesToRadians(-30.0f), 0.0f, 1.0f, 0.0f);
    for (int f=0; f<6; f++) {
        _cubeEffects[f].effect.transform.projectionMatrix = projectionMatrix;
    }
    [self drawCube];
}

- (void)drawCube {
    // 旋转的角度递增值
    _cubeRot += 2;
    
    // 初始位置在（0,0,0)屏幕正中央
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, 0);
    // 缩放
    modelView = GLKMatrix4Scale(modelView, kCubeScale, kCubeScale, kCubeScale);
    
    // 旋转
    modelView = GLKMatrix4Rotate(modelView, DegreesToRadians(_cubeRot), 1, 0, 0);
    modelView = GLKMatrix4Rotate(modelView, DegreesToRadians(_cubeRot), 0, 1, 1);
    modelView = GLKMatrix4RotateY(modelView, DegreesToRadians(_cubeRot));
    
    for (int f=0; f<6; f++) {
        _cubeEffects[f].effect.transform.modelviewMatrix = modelView;
        glBindVertexArrayOES(_cubeEffects[f].vertexArray);
        
        /*
         iOS的OpenGL中里有2个着色器，
         一个是GLKBaseEffect，为了方便OpenGL ES 1.0转移到2.0的通用着色器。
         一个是OpenGL ES 2.0新添加的可编程着色器，使用跨平台的着色语言实例化基础效果实例，
         如果没有GLKit与GLKBaseEffect类，就需要为这个简单的例子编写一个小的GPU程序，使用2.0的Shading Language，
         而GLKBaseEffect会在需要的时候自动的构建GPU程序。
         
         这里使用GLKBaseEffect来做着色器
         */
        [_cubeEffects[f].effect prepareToDraw];
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
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
