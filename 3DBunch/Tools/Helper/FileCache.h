//
//  FileCache.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/2.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AICommonDef.h"


@interface FileCache : NSObject

AISINGLETON_DEF(FileCache, sharedFileCache)

/**
 * 内存消耗大小
 */
@property(assign, nonatomic) NSInteger maxMemeryCacheCost;
/**
 * 磁盘缓存生命值
 */
@property(assign, nonatomic) NSInteger maxCacheAge;
/**
 * 磁盘缓存区大小
 */
@property(assign, nonatomic) NSInteger maxCacheSize;

/**
 * 工厂方式：生成一个全局的唯一的fileKey，使用者也可以自己定义生成fileKey
 */
+ (NSString *_Nonnull)fileKey;

/**
 * 向缓存中写数据
 */
- (void)writeData:(NSData *_Nonnull)data forKey:(NSString *_Nonnull)key;

- (void)writeData:(NSData *_Nonnull)data path:(NSString *_Nonnull)path;

/**
 * 从缓存中获取数据
 */
- (NSData *_Nullable)dataFromCacheForKey:(NSString *_Nonnull)key;

/**
 * 从缓存中获取数据
 */
- (NSData *_Nullable)dataFromCacheForPath:(NSString *_Nonnull)path;

/**
 * 文件路径
 */
- (NSString *_Nullable)diskCachePathForKey:(NSString *_Nonnull)key;

/**
 * 清除内存缓存数据
 */
- (void)cleanCacheMemory;

- (void)removeFileForKey:(NSString *_Nonnull)key;
- (void)removeFileForPath:(NSString *_Nonnull)path;

@end
