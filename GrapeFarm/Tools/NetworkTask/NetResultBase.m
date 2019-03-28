//
//  NetResultBase.m
//  
//
//  Created by wuyj on 14-9-2.
//  Copyright (c) 2014年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "NSObject+Utility.h"

@implementation NetResultBase

- (id)copyWithZone:(nullable NSZone *)zone {
    NetResultBase * temp = [[NetResultBase alloc] init];
    [temp setStatusCode:_statusCode];
    [temp setStatusDesc:_statusDesc];
    
    return temp;
}


// 自动解析Json
// ！！！！！！目前仅支持整个报文解析成字典类型
- (void)autoParseJsonData:(NSData *)jsonData{
    
    NSError * error = nil;
    // 目前仅支持整个报文解析成字典类型
    NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

    if (jsonDictionary != nil && error == nil) {
        NSLog(@"Successfully JSON parse...");
        
        if ([jsonDictionary objectForKey:@"statusCode"]) {
            self.statusCode = [jsonDictionary objectForKey:@"statusCode"];
        }
        
        if ([jsonDictionary objectForKey:@"statusDesc"]) {
            self.statusDesc = [jsonDictionary objectForKey:@"statusDesc"];
        }
        
        // 解析
        id data = [jsonDictionary objectForKey:@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            // 统一规范，data里面拿出来也是一个json
            [self parseNetResult:data];
        } else {
            
        }
    }
}

// 解析业务数据
- (void)parseNetResult:(NSDictionary *)jsonDictionary
{
    // 开始自动化解析
    [self parseJsonAutomatic:jsonDictionary];
}

@end
