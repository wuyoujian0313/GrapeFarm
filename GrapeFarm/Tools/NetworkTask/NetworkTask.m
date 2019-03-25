//
//  NetworkTask.m
//  CommonProject
//
//  Created by wuyoujian on 16/7/4.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import "NetworkTask.h"
#import "NetResultBase.h"
#import "../AFNetworking/AFNetworking.h"

#if DEBUG
#define RESPONSE_LOG \
NSData *responseData = responseObject; \
NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];\
NSLog(@"response:%@",responseStr);
#else
#define RESPONSE_LOG
#endif

@implementation UploadFileInfo
@end

@interface NetworkTask ()
@property (nonatomic,strong)AFHTTPSessionManager *afManager;
@end


@implementation NetworkTask

AISINGLETON_IMP(NetworkTask, sharedNetworkTask)

- (instancetype)init {
    
    if (self = [super init]) {
        self.taskTimeout = 20;
        self.afManager = [AFHTTPSessionManager manager];
        
        [_afManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_afManager.requestSerializer setHTTPMethodsEncodingParametersInURI:[NSSet setWithObjects:@"GET",@"DELETE",nil]];
        [_afManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        NSMutableSet *acceptContentTypes = [NSMutableSet setWithSet:_afManager.responseSerializer.acceptableContentTypes];
        [acceptContentTypes addObject:@"text/plain"];
        [acceptContentTypes addObject:@"text/html"];
        [acceptContentTypes addObject:@"text/javascript"];
        [acceptContentTypes addObject:@"text/xml"];
        [acceptContentTypes addObject:@"application/json"];
        [acceptContentTypes addObject:@"application/json; charset=utf-8"];
        [_afManager.responseSerializer setAcceptableContentTypes:acceptContentTypes];
    }
    
    return self;
}

#pragma mark - 私有API

-(void)analyzeData:(NSData *)responseObject
          delegate:(id <NetworkTaskDelegate>)delegate
         resultObj:(NetResultBase*)resultObj
        customInfo:(id)customInfo {
    
    [resultObj autoParseJsonData:responseObject];
    
    if(resultObj.code != nil && NetStatusCodeSuc([resultObj.code integerValue])) {
        
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultSuccessBack:forInfo:)]) {
            [delegate netResultSuccessBack:resultObj forInfo:customInfo];
        }
    } else if(resultObj.code != nil && NetStatusCodeFail([resultObj.code integerValue])) {
        
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            NSString *errorDesc = [[self class] errerDescription:[resultObj.code integerValue]];
            if (errorDesc != nil && [errorDesc length] > 0) {
                [delegate netResultFailBack:errorDesc errorCode:[resultObj.code integerValue]  forInfo:customInfo];
            } else {
                [delegate netResultFailBack:resultObj.message errorCode:[resultObj.code integerValue]  forInfo:customInfo];
            }
        }
        
    } else {
        
        NSString *errorDesc = [[self class] errerDescription:NetStatusCodeUnknown];
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            [delegate netResultFailBack:errorDesc errorCode:NetStatusCodeUnknown forInfo:customInfo];
        }
    }
}

-(void)handleError:(NSError *)error
          delegate:(id <NetworkTaskDelegate>)delegate
  receiveResultObj:(NetResultBase*)resultObj
        customInfo:(id)customInfo {
    
    if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
        [delegate netResultFailBack:[error localizedDescription] errorCode:error.code forInfo:customInfo];
    }
}

- (void)requestWithMethod:(NSString *)method
                      api:(NSString *)api
                    param:(NSDictionary *)param
                 delegate:(id <NetworkTaskDelegate>)delegate
                resultObj:(NetResultBase*)resultObj
               customInfo:(id)customInfo {
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    __weak NetworkTask *weakSelf = self;
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",_serverAddress,api];
    if ([method isEqualToString:@"GET"]) {
        
        [_afManager GET:urlString parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
            //
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            RESPONSE_LOG
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            //
            if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
                [delegate netResultFailBack:[error localizedDescription] errorCode:error.code forInfo:customInfo];
            }
        }];
        
    } else if([method isEqualToString:@"POST"]) {
        
        [_afManager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            //
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //
            RESPONSE_LOG
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            [weakSelf handleError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
        
    } else if([method isEqualToString:@"PUT"]) {
        
        [_afManager PUT:urlString parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            //
            RESPONSE_LOG
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            [weakSelf handleError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
        
    } else if([method isEqualToString:@"DELETE"]) {
        
        [_afManager DELETE:urlString parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            //
            RESPONSE_LOG
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            
            [weakSelf handleError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
    }
}

#pragma mark - 公开API
- (void)startUploadTaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                     files:(NSArray<UploadFileInfo*>*)files
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",_serverAddress,api];
    
    __weak NetworkTask *weakSelf = self;
    
    [_afManager POST:urlString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //
        for (UploadFileInfo *info in files) {
            [formData appendPartWithFileData:info.fileData name:info.fileKey fileName:info.fileName mimeType:info.mimeType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        RESPONSE_LOG
        [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
        [weakSelf handleError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
    }];
}

- (void)startGETTaskURL:(NSString*)urlString
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:( NetResultBase*)resultObj
             customInfo:(id)customInfo {
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    __weak NetworkTask *weakSelf = self;
    
    [_afManager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        //
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        RESPONSE_LOG
        [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
        [weakSelf handleError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
    }];
}

- (void)startUploadTaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                  fileData:(NSData*)fileData
                   fileKey:(NSString*)fileKey
                  fileName:(NSString*)fileName
                  mimeType:(NSString*)mimeType
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    UploadFileInfo *uInfo = [[UploadFileInfo alloc] init];
    uInfo.fileData = fileData;
    uInfo.fileKey = fileKey;
    uInfo.fileName = fileName;
    uInfo.mimeType = mimeType;
    
    NSArray *files = [NSArray arrayWithObject:uInfo];
    [self startUploadTaskApi:api forParam:param files:files delegate:delegate resultObj:resultObj customInfo:customInfo];
}


- (void)startUploadTaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                  filePath:(NSString*)filePath
                   fileKey:(NSString*)fileKey
                  fileName:(NSString*)fileName
                  mimeType:(NSString*)mimeType
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    
    UploadFileInfo *uInfo = [[UploadFileInfo alloc] init];
    uInfo.fileData = [NSData dataWithContentsOfFile:filePath];
    uInfo.fileKey = fileKey;
    uInfo.fileName = fileName;
    uInfo.mimeType = mimeType;
    
    NSArray *files = [NSArray arrayWithObject:uInfo];
    [self startUploadTaskApi:api forParam:param files:files delegate:delegate resultObj:resultObj customInfo:customInfo];
}

- (void)startGETTaskApi:(NSString*)api
               forParam:(NSDictionary *)param
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:(NetResultBase*)resultObj
             customInfo:(id)customInfo {
    
    [self requestWithMethod:@"GET"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}

- (void)startPOSTTaskApi:(NSString*)api
                forParam:(NSDictionary *)param
                delegate:(id <NetworkTaskDelegate>)delegate
               resultObj:(NetResultBase*)resultObj
              customInfo:(id)customInfo {
    
    [self requestWithMethod:@"POST"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}


- (void)startPUTTaskApi:(NSString*)api
               forParam:(NSDictionary *)param
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:(NetResultBase*)resultObj
             customInfo:(id)customInfo {
    
    [self requestWithMethod:@"PUT"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}

- (void)startDELETETaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    [self requestWithMethod:@"DELETE"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}


+ (NSString *)errerDescription:(NSInteger)statusCode {
    NSMutableString *desc = [[NSMutableString alloc] initWithCapacity:0];
    
    switch (statusCode) {
        case NetStatusCodeMAPSuccess:
        case NetStatusCodeSuccess: {
            [desc appendString:@"成功"];
            break;
        }
            
        case NetStatusCodeUnknown: {
            [desc appendString:@"未知错误，请重试"];
            break;
        }
            
        default:
            break;
    }
    
    return desc;
}

@end
