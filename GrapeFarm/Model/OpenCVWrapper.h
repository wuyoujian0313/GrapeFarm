//
//  OpenCVWrapper.h
//  superscaner
//
//  Created by Yanxin on 2019/4/1.
//  Copyright © 2019 Yanxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Circle : NSObject
@property(nonatomic,strong)NSNumber *x;
@property(nonatomic,strong)NSNumber *y;
@property(nonatomic,strong)NSNumber *r;
@end


@interface OpenCVWrapper : NSObject

+ (UIImage *)toBlue:(UIImage *)source;
+ (UIImage *)toGreen:(UIImage *)source;
+ (UIImage *)toRed:(UIImage *)source;
+ (UIImage *)Rededge:(UIImage *)source;
+ (UIImage *)Rededge:(UIImage *)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3;
+ (NSArray *)edgeCircles:(UIImage *)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 value4:(NSInteger)value4;
@end
