//
//  NetResultBase.h
//
//
//  Created by wuyj on 14-9-2.
//  Copyright (c) 2014年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBaiduParserArray(key,type)    key##__Array__##type
/* 定义数组字段的范例：
 @property (nonatomic, strong, getter=getList) NSArray *kBaiduParserArray(key,className);
 key：字段名称
 className：数组item类型
 getList：重定义get函数，一般定义，不然get名就是：key##__Array__##type
 */


@interface NetResultBase : NSObject<NSCopying>

@property (nonatomic, copy)NSNumber     *statusCode;                 // 返回代码
@property (nonatomic, copy)NSString     *statusDesc;                 // 返回描述


// 自动解析Json
// ！！！！！！目前仅支持整个报文解析成字典类型
- (void)autoParseJsonData:(NSData*)result;
- (void)parseNetResult:(NSDictionary *)jsonDictionary;


@end
