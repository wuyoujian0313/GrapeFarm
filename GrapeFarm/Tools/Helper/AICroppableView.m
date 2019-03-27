//
//  AICroppableView.m
//  BaiduTong
//
//  Created by wuyj on 14-11-24.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "AICroppableView.h"
#import "UIBezierPath+Points.h"

@interface AICroppableView ()
@property(nonatomic, strong) UIBezierPath *croppingPath;
@end

@implementation AICroppableView

- (void)cleaningBrush {
    [_croppingPath removeAllPoints];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.lineColor setStroke];
    [self.croppingPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
}

- (UIImage *)croppingOfImage:(UIImage*)image{
    NSArray *points = [self.croppingPath points];
    
    CGRect rect = CGRectZero;
    rect.size = image.size;
    
    UIBezierPath *aPath;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    {
        [[UIColor blackColor] setFill];
        UIRectFill(rect);
        [[UIColor whiteColor] setFill];
        
        aPath = [UIBezierPath bezierPath];
        
        // Set the starting point of the shape.
        CGPoint p1 = [[self class] convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:self.frame.size toRect2:image.size];
        [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
        
        for (uint i=1; i<points.count; i++) {
            CGPoint p = [[self class] convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:self.frame.size toRect2:image.size];
            [aPath addLineToPoint:CGPointMake(p.x, p.y)];
        }
        [aPath closePath];
        [aPath fill];
    }
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        [image drawAtPoint:CGPointZero];
    }
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect croppedRect = aPath.bounds;
    croppedRect.origin.y = rect.size.height - CGRectGetMaxY(aPath.bounds);//This because mask become inverse of the actual image;
    
    croppedRect.origin.x = croppedRect.origin.x*2;
    croppedRect.origin.y = croppedRect.origin.y*2;
    croppedRect.size.width = croppedRect.size.width*2;
    croppedRect.size.height = croppedRect.size.height*2;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, croppedRect);
    
    maskedImage = [UIImage imageWithCGImage:imageRef];
    
    return maskedImage;
}
#pragma mark - Touch Methods -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [self.croppingPath moveToPoint:[mytouch locationInView:self]];
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [self.croppingPath addLineToPoint:[mytouch locationInView:self]];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 5.0f;
        self.lineColor = [UIColor redColor];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        [self setUserInteractionEnabled:YES];
        self.croppingPath = [[UIBezierPath alloc] init];
        [self.croppingPath setLineWidth:self.lineWidth];
        
    }
    return self;
}

+ (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2 {
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}


@end
