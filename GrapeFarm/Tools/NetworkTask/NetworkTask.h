//
//  NetworkTask.h
//  CommonProject
//
//  Created by wuyoujian on 16/7/4.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Owns/AICommonDef.h"


typedef NS_ENUM(NSInteger, NetStatusCode) {
    NetStatusCodeSuccess = 1000,
    NetStatusCodeMAPSuccess = 0,
    NetStatusCodeUnknown,
};


#define NetStatusCodeSuc(status)    (status == NetStatusCodeSuccess || status == NetStatusCodeMAPSuccess)
#define NetStatusCodeFail(status)    (status != NetStatusCodeSuccess && status != NetStatusCodeMAPSuccess)

@interface UploadFileInfo : NSObject
@property(nonatomic,copy) NSString      * _Nonnull fileName;
@property(nonatomic,copy) NSString      * _Nonnull mimeType;
@property(nonatomic,strong) NSData      * _Nonnull fileData;
@property(nonatomic,copy) NSString      * _Nonnull fileKey;
@end


@class NetResultBase;
@protocol NetworkTaskDelegate <NSObject>

@optional
-(void)netResultSuccessBack:(NetResultBase *_Nonnull)result forInfo:(id _Nonnull )customInfo;
-(void)netResultFailBack:(NSString *_Nonnull)errorDesc errorCode:(NSInteger)errorCode forInfo:(id _Nonnull )customInfo;

@end

@interface NetworkTask : NSObject

@property(nonatomic, assign) NSTimeInterval taskTimeout;
@property(nonatomic, copy) NSString         * _Nonnull serverAddress;

AISINGLETON_DEF(NetworkTask, sharedNetworkTask)

+(NSString *_Nonnull)errerDescription:(NSInteger)statusCode;

// upload File 带上传文件的
- (void)startUploadTaskApi:(NSString*_Nonnull)api
                  forParam:(NSDictionary *_Nonnull)param
                  fileData:(NSData*_Nonnull)fileData
                   fileKey:(NSString*_Nonnull)fileKey
                  fileName:(NSString*_Nonnull)fileName
                  mimeType:(NSString*_Nonnull)mimeType
                  delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
                 resultObj:(NetResultBase*_Nonnull)resultObj
                customInfo:(id _Nonnull)customInfo;

- (void)startUploadTaskApi:(NSString*_Nonnull)api
                  forParam:(NSDictionary *_Nonnull)param
                  filePath:(NSString*_Nonnull)filePath
                   fileKey:(NSString*_Nonnull)fileKey
                  fileName:(NSString*_Nonnull)fileName
                  mimeType:(NSString*_Nonnull)mimeType
                  delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
                 resultObj:(NetResultBase*_Nonnull)resultObj
                customInfo:(id _Nonnull)customInfo;

- (void)startUploadTaskApi:(NSString*_Nonnull)api
                  forParam:(NSDictionary *_Nonnull)param
                     files:(NSArray<UploadFileInfo*>*_Nonnull)files
                  delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
                 resultObj:(NetResultBase*_Nonnull)resultObj
                customInfo:(id _Nonnull)customInfo;

// GET
- (void)startGETTaskURL:(NSString*_Nonnull)urlString
               delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
              resultObj:(NetResultBase*_Nonnull)resultObj
             customInfo:(id _Nonnull)customInfo;

- (void)startGETTaskApi:(NSString*_Nonnull)api
               forParam:(NSDictionary *_Nonnull)param
               delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
              resultObj:(NetResultBase*_Nonnull)resultObj
             customInfo:(id _Nonnull)customInfo;

// POST
- (void)startPOSTTaskApi:(NSString*_Nonnull)api
                forParam:(NSDictionary *_Nonnull)param
                delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
               resultObj:(NetResultBase*_Nonnull)resultObj
              customInfo:(id _Nonnull)customInfo;

// PUT
- (void)startPUTTaskApi:(NSString*_Nonnull)api
               forParam:(NSDictionary *_Nonnull)param
               delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
              resultObj:(NetResultBase*_Nonnull)resultObj
             customInfo:(id _Nonnull)customInfo;

// DELETE
- (void)startDELETETaskApi:(NSString*_Nonnull)api
                  forParam:(NSDictionary *_Nonnull)param
                  delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
                 resultObj:(NetResultBase*_Nonnull)resultObj
                customInfo:(id _Nonnull )customInfo;

@end
