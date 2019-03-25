//
//  NetResultBase.m
//  
//
//  Created by wuyj on 14-9-2.
//  Copyright (c) 2014年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "../Category/NSObject+Utility.h"

@implementation NetResultBase

- (id)copyWithZone:(nullable NSZone *)zone {
    NetResultBase * temp = [[NetResultBase alloc] init];
    [temp setCode:_code];
    [temp setMessage:_message];
    
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
        
        if ([jsonDictionary objectForKey:@"code"]) {
            self.code = [jsonDictionary objectForKey:@"code"];
        } else if ([jsonDictionary objectForKey:@"status"]) {
            self.code = [jsonDictionary objectForKey:@"status"];
        } else {
            self.code = [jsonDictionary objectForKey:@"code"];
        }
        
        if ([jsonDictionary objectForKey:@"message"]) {
            self.message = [jsonDictionary objectForKey:@"message"];
        } else if ([jsonDictionary objectForKey:@"msg"]) {
            self.message = [jsonDictionary objectForKey:@"msg"];
        } else {
            self.message = [jsonDictionary objectForKey:@"message"];
        }
        
        if (self.code != nil) {
            // 解析
            
            NSString *dataJson = nil;
            if ([jsonDictionary objectForKey:@"data"]) {
                dataJson = @"data";
            } else {
                dataJson = @"result";
            }
            
            id data = [jsonDictionary objectForKey:dataJson];
            if ([data isKindOfClass:[NSDictionary class]]) {
                [self parseNetResult:data];
            } else {
                // 统一规范，data里面拿出来也是一个json
            }
            
            
        } else {
            // 解析
            [self parseNetResult:jsonDictionary];
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
