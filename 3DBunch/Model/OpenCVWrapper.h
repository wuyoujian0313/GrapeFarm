//
//  OpenCVWrapper.h
//  superscaner
//
//  Created by Yanxin on 2019/4/1.
//  Copyright © 2019 Yanxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *)toBlue:(UIImage *)source;
+ (UIImage *)toGreen:(UIImage *)source;
+ (UIImage *)toRed:(UIImage *)source;
+ (UIImage *)toL:(UIImage *)source;
+ (UIImage *)toA:(UIImage *)source;
+ (UIImage *)toB:(UIImage *)source;
+ (UIImage *)Rededge:(UIImage *)source;
+ (UIImage *)Rededge:(UIImage *)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3;

//threshold，distance，type
+ (NSArray *)edgeCircles:(UIImage *)source threshold:(NSInteger)threshold distance:(NSInteger)distance type:(NSInteger)type gtype:(NSInteger)gtype;
@end
