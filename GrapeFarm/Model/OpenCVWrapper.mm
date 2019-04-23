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

+ (UIImage *)Blueedge:(UIImage *)source{
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _blueedgeFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)Greenedge:(UIImage *)source{
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _greenedgeFrom:[OpenCVWrapper _matFrom:source]]];
}

#pragma mark Private

+ (Mat)_rededgeFrom:(Mat)source {
    cout << "-> rededgeFrom ->";
    
    std::vector<Mat> channels;
    Mat imageRedChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageRedChannel = channels.at(2);
    Mat gaussianBlur;
    GaussianBlur(imageRedChannel, gaussianBlur, cv::Size(5,5), 2,2);
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

+ (Mat)_blueedgeFrom:(Mat)source {
    cout << "-> blueedgeFrom ->";
    
    std::vector<Mat> channels;
    Mat imageBlueChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageBlueChannel = channels.at(0);
    Mat gaussianBlur;GaussianBlur(imageBlueChannel, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;Canny(gaussianBlur, edges, 0, 50);
    //显示分离的单通道图像∫
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 10,
                 1, 79, 150, 250 );
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        circle( source, Point2i(c[0], c[1]), c[2], Scalar(0,255,0), 10);
        circle( source, Point2i(c[0], c[1]), 2, Scalar(0,255,0), 10);
        
    }
    return source;

    
}

+ (Mat)_greenedgeFrom:(Mat)source {
    cout << "-> greenedgeFrom ->";
    
    std::vector<Mat> channels;
    Mat imageGreenChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageGreenChannel = channels.at(1);
    Mat gaussianBlur;GaussianBlur(imageGreenChannel, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;Canny(gaussianBlur, edges, 0, 50);
    //显示分离的单通道图像∫
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 10,
                 1, 79, 150, 250 );
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        circle( source, Point2i(c[0], c[1]), c[2], Scalar(0,255,0), 10);
        circle( source, Point2i(c[0], c[1]), 2, Scalar(0,255,0), 10);
        
    }
    return source;

    
}

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