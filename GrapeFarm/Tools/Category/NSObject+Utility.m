//
//  NSObject+Utility.m
//
//
//  Created by wuyj on 14-9-1.
//  Copyright (c) 2014年 wuyj. All rights reserved.
//

#import "NSObject+Utility.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>


@implementation NSObject (Utility)

// 自动解析Json
- (void)parseJsonAutomatic:(NSDictionary *)dictionaryJson
{
    // 如果Json数据无效,产生Sentry Json
    if(dictionaryJson == nil)
    {
        dictionaryJson = [[NSDictionary alloc] init];
    }
    
    // 获取对象
    NSString *className = NSStringFromClass([self class]);
    const char *cClassName = [className UTF8String];
    id theClass = objc_getClass(cClassName);
    
    // 获取property
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(theClass, &propertyCount);
    for(unsigned int i = 0; i < propertyCount; i++)
    {
        // 获取Var
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyType = [[NSString alloc] initWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        Ivar iVar = class_getInstanceVariable([self class], [propertyName UTF8String]);
        if(iVar == nil)
        {
            // 采用另外一种方法尝试获取
            iVar = class_getInstanceVariable([self class], [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
        }
        
        // 获取Name
        if((iVar != nil) && (![dictionaryJson isEqual:[NSNull null]]))
        {
            // 通过propertyName去Json中寻找Value
            id jsonValue = [dictionaryJson objectForKey:propertyName];
            
            
            if ([propertyType hasPrefix:@"T@\"NSString\""])
            {
                if (jsonValue != nil && ([jsonValue isKindOfClass:[NSString class]] || [jsonValue isKindOfClass:[NSMutableString class]]))
                {
                    object_setIvar(self, iVar, jsonValue);
                }
            }
            else if ([propertyType hasPrefix:@"T@\"NSMutableString\""])
            {
                if (jsonValue != nil && ([jsonValue isKindOfClass:[NSString class]] || [jsonValue isKindOfClass:[NSMutableString class]]))
                {
                    object_setIvar(self, iVar, jsonValue);
                }
            }
            else if ([propertyType hasPrefix:@"T@\"NSNumber\""])
            {
                if (jsonValue != nil && [jsonValue isKindOfClass:[NSNumber class]])
                {
                    object_setIvar(self, iVar, jsonValue);
                }
            }
            else if ([propertyType hasPrefix:@"T@\"NSArray\""] || [propertyType hasPrefix:@"T@\"NSMutableArray\""])
            {
                NSArray *arrayVarInfo = [propertyName componentsSeparatedByString:@"__Array__"];
                if ([arrayVarInfo count] == 2)
                {
                    NSString *keyValue = [arrayVarInfo objectAtIndex:0];
                    NSString *varClassName = [arrayVarInfo objectAtIndex:1];
                    
                    jsonValue = [dictionaryJson objectForKey:keyValue];
                    
                    if (jsonValue != nil && ([jsonValue isKindOfClass:[NSArray class]] || [jsonValue isKindOfClass:[NSMutableArray class]]))
                    {
                        NSMutableArray *arrayDest = [[NSMutableArray alloc] init];
                        
                        // 基本数据类型
                        if(([varClassName isEqualToString:@"NSString"]) || ([varClassName isEqualToString:@"NSNumber"]))
                        {
                            // 解析
                            NSInteger jsonCount = [jsonValue count];
                            for(NSInteger i = 0; i < jsonCount; i++)
                            {
                                id varObject = [jsonValue objectAtIndex:i];
                                [arrayDest addObject:varObject];
                            }
                        }
                        else
                        {
                            Class varClass = NSClassFromString(varClassName);
                            
                            // 解析
                            NSInteger jsonCount = [jsonValue count];
                            for(NSInteger i = 0; i < jsonCount; i++)
                            {
                                NSDictionary *dictionaryJsonValue = [jsonValue objectAtIndex:i];
                                if(dictionaryJsonValue != nil)
                                {
                                    NSObject *varObject = [[varClass alloc] init];
                                    
                                    if(varObject != nil)
                                    {
                                        [varObject parseJsonAutomatic:dictionaryJsonValue];
                                        [arrayDest addObject:varObject];
                                    }
                                }
                            }
                        }
                        
                        // 赋值
                        object_setIvar(self, iVar, arrayDest);
                    }
                }
            }
            else if ([propertyType hasPrefix:@"T@\""])
            {
                if (jsonValue != nil && ([jsonValue isKindOfClass:[NSDictionary class]] || [jsonValue isKindOfClass:[NSMutableDictionary class]]))
                {
                    NSArray *arrayTypeInfo = [propertyType componentsSeparatedByString:@"\""];
                    if ([arrayTypeInfo count] > 2)
                    {
                        NSString *varClassName = [arrayTypeInfo objectAtIndex:1];
                        
                        // 创建对象
                        Class varClass = NSClassFromString(varClassName);
                        if (varClass != nil)
                        {
                            NSObject *varObject = [[varClass alloc] init];
                            [varObject parseJsonAutomatic:jsonValue];
                            
                            // 赋值
                            object_setIvar(self, iVar, varObject);
                        }
                    }
                }
            }
        }
    }
    
    free(properties);
}


@end

