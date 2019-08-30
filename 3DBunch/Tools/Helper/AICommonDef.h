//
//  AICommonDef.h
//  CommonProject
//
//  Created by wuyoujian on 16/9/1.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#ifndef AICommonDef_h
#define AICommonDef_h

// 定义单例方法，有些类是允许非单例模式的
#ifndef _AISINGLETON_API_
#define _AISINGLETON_API_

#define AISINGLETON_DEF(type,APIName)       + ( type * _Nonnull) APIName;
#define AISINGLETON_IMP(type,APIName)       \
+ ( type * _Nonnull) APIName {              \
    static type *obj = nil;                 \
    static dispatch_once_t onceToken;       \
    dispatch_once(&onceToken, ^{            \
        obj = [[self alloc] init];          \
    });                                     \
    return obj;                             \
}
#endif // _AISINGLETON_API_

// 定义单例类
#ifndef _AISINGLETON_CLASS_
#define _AISINGLETON_CLASS_

#define AISINGLETON_CLASS_DEF(type,APIName)             + ( type * _Nonnull) APIName;
#define AISINGLETON_CLASS_IMP(type,APIName)             \
+ ( type * _Nonnull) APIName {                          \
    static type *obj = nil;                             \
    static dispatch_once_t onceToken;                   \
    dispatch_once(&onceToken, ^{                        \
        obj = [[super allocWithZone:NULL] init];        \
    });                                                 \
    return obj;                                         \
}                                                       \
                                                        \
+ (instancetype)allocWithZone:(struct _NSZone * _Nonnull)zone {  \
    return [self APIName ];                             \
}                                                       \
                                                        \
- (instancetype)copy{                                   \
    return [[self class] APIName ];                     \
}
#endif // _AISINGLETON_CLASS_



#endif /* AICommonDef_h */
