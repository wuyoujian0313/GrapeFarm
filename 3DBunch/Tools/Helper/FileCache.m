//
//  FileCache.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/2.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "FileCache.h"
#import <UIKit/UIKit.h>
#import "NSString+Utility.h"

#define MEMORY_CACHE_NAME               @"com.wuyj.Filecache"
#define DISK_CACHE_NAMESPACE            @"com.wuyj.Filecache"
#define DISPATCH_QUEUE_CAHCE            "com.wuyj.FileCacheQueue"


static const NSInteger kCacheMaxAge = 60 * 60 * 24 * 7; //每周清除一次
@interface FileCache (){
    NSFileManager *_fileManager;
}

@property(nonatomic, strong) NSCache            *memoryCache;
@property(nonatomic, strong) dispatch_queue_t   rwQueue;
@property(nonatomic, copy) NSString             *diskCachePath;

@end

@implementation FileCache

+ (NSString *)fileKey {
    return [NSString UUID];
}


AISINGLETON_IMP(FileCache, sharedFileCache)

- (instancetype)init {
    self = [super init];
    if (self) {
        _memoryCache = [[NSCache alloc]init];
        _memoryCache.name = MEMORY_CACHE_NAME;
        _maxCacheAge = kCacheMaxAge;
        _maxCacheSize = 1024*1024*200;
        _rwQueue = dispatch_queue_create(DISPATCH_QUEUE_CAHCE, DISPATCH_QUEUE_SERIAL);
        _diskCachePath = [self createDiskCachePathWithNamespace:DISK_CACHE_NAMESPACE];
        __weak typeof(self) wSelf = self;
        dispatch_sync(_rwQueue, ^{
            typeof (self) sSelf = wSelf;
            sSelf->_fileManager = [[NSFileManager alloc]init];
            
            if (![sSelf->_fileManager fileExistsAtPath:sSelf.diskCachePath]) {
                [sSelf->_fileManager createDirectoryAtPath:sSelf.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
        });
        
#if TARGET_OS_IPHONE
        // 系统通知处理
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(cleanCacheMemory)
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(cleanCacheDisk)
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanCacheDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
#endif
    return self;
}

- (void)writeData:(NSData *)data forKey:(NSString *)key {
    if (!data||!key) {
        return;
    }
    
    // 放入内存中
    [self.memoryCache setObject:data forKey:key];
    // 放入磁盘中
    __weak typeof(self) wSelf = self;
    dispatch_async(_rwQueue, ^{
        typeof(self) sSelf = wSelf;
        if (![sSelf->_fileManager fileExistsAtPath:sSelf.diskCachePath]) {
            [sSelf->_fileManager createDirectoryAtPath:sSelf.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        [sSelf->_fileManager createFileAtPath:[sSelf diskCachePathForKey:key] contents:data attributes:nil];
    });
}

- (void)writeData:(NSData *)data path:(NSString *)path {
    if (!data||!path) {
        return;
    }
    
    // 放入磁盘中
    __weak typeof(self) wSelf = self;
    dispatch_async(_rwQueue, ^{
        typeof(self) sSelf = wSelf;
        [sSelf->_fileManager createFileAtPath:path contents:data attributes:nil];
    });
    
}

- (NSData *)dataFromCacheForKey:(NSString *)key {
    // 检查缓存中是否有该二进制数据
    id data = [self.memoryCache objectForKey:key];
    if (data) {
        return data;
    }
    
    
    // 检查硬盘中该二进制数据
    NSData *diskData = [self dataFromDiskForKey:key];
    if (diskData) {
        // 置入缓存数据
        [self.memoryCache setObject:diskData forKey:key];
        return diskData;
    }
    return nil;
}

- (NSData *)dataFromCacheForPath:(NSString *)path {
    NSData *diskData = [NSData dataWithContentsOfFile:path];
    if (diskData) {
        return diskData;
    }
    return nil;
}


#pragma mark - private func
- (NSString *)diskCachePathForKey:(NSString *)key {
    NSString *filename = [key md5EncodeUpper:NO];
    NSString *filepath = [self.diskCachePath stringByAppendingPathComponent:filename];
    return filepath;
}

- (NSData *)dataFromDiskForKey:(NSString *)key {
    
    NSString *filepath = [self diskCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    if (data) {
        return data;
    }
    return nil;
}

- (void)removeFileForKey:(NSString *)key {
    
    if (key == nil) {
        return;
    }
    
    [self.memoryCache removeObjectForKey:key];
    
    __weak typeof(self) wSelf = self;
    dispatch_async(self.rwQueue, ^{
        typeof(self) sSelf = wSelf;
        [sSelf->_fileManager removeItemAtPath:[sSelf diskCachePathForKey:key] error:nil];
    });
}

- (void)removeFileForPath:(NSString *)path {
    __weak typeof(self) wSelf = self;
    dispatch_async(self.rwQueue, ^{
        typeof(self) sSelf = wSelf;
        [sSelf->_fileManager removeItemAtPath:path error:nil];
    });
}

#pragma mark - notification func
/**
 * 虽然NSCache会在内存吃紧的时候进行清空，但是不确定时机，在这里额外加上内存清空处理
 */
- (void)cleanCacheMemory {
    [self.memoryCache removeAllObjects];
}

/**
 * 对于磁盘缓存数据进行清理，此函数的调用时机有待考虑
 */
- (void)cleanCacheDisk {
    __weak typeof(self) wSelf = self;
    dispatch_async(self.rwQueue, ^{
        typeof(self) sSelf = wSelf;
        NSURL *diskCacheURL = [NSURL fileURLWithPath:sSelf.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        NSDirectoryEnumerator *fileEnumerator = [sSelf->_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-sSelf.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            // 跳过
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            // 删除过期文件
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        for (NSURL *fileURL in urlsToDelete) {
            [sSelf->_fileManager removeItemAtURL:fileURL error:nil];
        }
        if (sSelf.maxCacheSize > 0 && currentCacheSize > sSelf.maxCacheSize) {
            const NSUInteger desiredCacheSize = sSelf.maxCacheSize / 2;
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            for (NSURL *fileURL in sortedFiles) {
                if ([sSelf->_fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
    });
}


-(NSString *)createDiskCachePathWithNamespace:(NSString *)namespace {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:namespace];
}
@end
