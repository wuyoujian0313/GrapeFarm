//
//  OpenCVWrapper.m
//  superscaner
//
//  Created by Yanxin on 2019/4/1.
//  Copyright © 2019 Yanxin. All rights reserved.
//
#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"


#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#pragma clang pop
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@implementation Circle
@end

@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (Mat)_blueFrom:(Mat)source;
+ (Mat)_greenFrom:(Mat)source;
+ (Mat)_redFrom:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public

+ (UIImage *)toBlue:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _blueFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toGreen:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _greenFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toRed:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _redFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)Rededge:(UIImage *)source{
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _rededgeFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)Rededge:(UIImage *)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _rededgeFrom:[OpenCVWrapper _matFrom:source] value1:value1 value2:value2 value3:value3]];
}


+ (NSArray *)edgeCircles:(UIImage *)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 {
    return [OpenCVWrapper _edgeCircles:[OpenCVWrapper _matFrom:source] value1:value1 value2:value2 value3:value3];
}

#pragma mark Private

//　Hough圆检测
+ (NSArray *)_edgeCircles:(Mat)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 {
    cout << "-> rededgeFrom ->";
    
    std::vector<Mat> channels;
    Mat imageRedChannel;
    
    //把一个三通道图像转化为三个单通道图像
    Mat gaussianBlur;
    GaussianBlur(source, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;
    Canny(gaussianBlur, edges, 0, 50);
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 10,
                 1, value1, (int)value2, (int)value3 ); //image:8位，单通道图像。如果使用彩色图像，需要先转换为灰度图像。method：定义检测图像中圆的方法。目前唯一实现的方法是cv2.HOUGH_GRADIENT。dp：累加器分辨率与图像分辨率的反比。dp获取越大，累加器数组越小。minDist：检测到的圆的中心，（x,y）坐标之间的最小距离。如果minDist太小，则可能导致检测到多个相邻的圆。如果minDist太大，则可能导致很多圆检测不到。param1：用于处理边缘检测的梯度值方法。param2：cv2.HOUGH_GRADIENT方法的累加器阈值。阈值越小，检测到的圈子越多。minRadius：半径的最小大小（以像素为单位）。maxRadius：半径的最大大小（以像素为单位）。
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for( size_t i = 0; i < circles.size(); i++ ) {
        Vec3i c = circles[i];
        Circle *circle = [[Circle alloc] init];
        circle.x = [NSNumber numberWithFloat:c[0]];
        circle.y = [NSNumber numberWithFloat:c[1]];
        circle.r = [NSNumber numberWithFloat:c[2]];
        
        [arr addObject:circle];
    }
    return arr;
}

//　Hough圆检测
+ (Mat)_rededgeFrom:(Mat)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 {
    cout << "-> hough ->";
    Mat gaussianBlur;
    GaussianBlur(source, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;
    Canny(gaussianBlur, edges, 0, 50);
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 10,
                 1, value1, value2, value3 ); //image:8位，单通道图像。如果使用彩色图像，需要先转换为灰度图像。method：定义检测图像中圆的方法。目前唯一实现的方法是cv2.HOUGH_GRADIENT。dp：累加器分辨率与图像分辨率的反比。dp获取越大，累加器数组越小。minDist：检测到的圆的中心，（x,y）坐标之间的最小距离。如果minDist太小，则可能导致检测到多个相邻的圆。如果minDist太大，则可能导致很多圆检测不到。param1：用于处理边缘检测的梯度值方法。param2：cv2.HOUGH_GRADIENT方法的累加器阈值。阈值越小，检测到的圈子越多。minRadius：半径的最小大小（以像素为单位）。maxRadius：半径的最大大小（以像素为单位）。
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        circle( source, Point2i(c[0], c[1]), c[2], Scalar(0,255,0), 0.1);
        circle( source, Point2i(c[0], c[1]), 2, Scalar(0,255,0), 0.1);
        
    }
    return source;
    
}

//　Hough圆检测
+ (Mat)_rededgeFrom:(Mat)source {
    cout << "-> rededgeFrom ->";
    
    std::vector<Mat> channels;
    Mat imageRedChannel;
    
    //把一个三通道图像转化为三个单通道图像
    Mat gaussianBlur;
    GaussianBlur(source, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;
    Canny(gaussianBlur, edges, 0, 50);
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 10,
                 1, 79, 150, 250 ); //image:8位，单通道图像。如果使用彩色图像，需要先转换为灰度图像。method：定义检测图像中圆的方法。目前唯一实现的方法是cv2.HOUGH_GRADIENT。dp：累加器分辨率与图像分辨率的反比。dp获取越大，累加器数组越小。minDist：检测到的圆的中心，（x,y）坐标之间的最小距离。如果minDist太小，则可能导致检测到多个相邻的圆。如果minDist太大，则可能导致很多圆检测不到。param1：用于处理边缘检测的梯度值方法。param2：cv2.HOUGH_GRADIENT方法的累加器阈值。阈值越小，检测到的圈子越多。minRadius：半径的最小大小（以像素为单位）。maxRadius：半径的最大大小（以像素为单位）。

    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        circle( source, Point2i(c[0], c[1]), c[2], Scalar(0,255,0), 10);
        circle( source, Point2i(c[0], c[1]), 2, Scalar(0,255,0), 10);

    }
    return source;
    
}

//RGB色彩分离
+ (Mat)_blueFrom:(Mat)source {
    cout << "-> blueFrom ->";
    
    std::vector<Mat> channels;
    Mat imageBlueChannel;

    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageBlueChannel = channels.at(0);

    //显示分离的单通道图像

    return imageBlueChannel;
    
}

+ (Mat)_greenFrom:(Mat)source {
    cout << "-> greenFrom ->";
    
    std::vector<Mat> channels;
    Mat imageGreenChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageGreenChannel = channels.at(1);
    
    //显示分离的单通道图像
    
    return imageGreenChannel;
    
}

+ (Mat)_redFrom:(Mat)source {
    cout << "-> redFrom ->";
    
    std::vector<Mat> channels;
    Mat imageRedChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageRedChannel = channels.at(2);
    
    //显示分离的单通道图像
    
    return imageRedChannel;
    
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "-> imageFrom\n";
    
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}


@end
