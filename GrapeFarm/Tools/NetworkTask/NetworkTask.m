//
//  NetworkTask.m
//  CommonProject
//
//  Created by wuyoujian on 16/7/4.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import "NetworkTask.h"
#import "NetResultBase.h"
#import "AFNetworking.h"

#if DEBUG
#define RESPONSE_LOG \
NSData *responseData = responseObject; \
NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];\
NSLog(@"response:%@",responseStr);
#else
#define RESPONSE_LOG
#endif

@interface NetworkTask ()
@property (nonatomic,strong)AFHTTPSessionManager *afManager;
@end


@implementation NetworkTask

AISINGLETON_IMP(NetworkTask, sharedNetworkTask)

- (instancetype)init {
    
    if (self = [super init]) {
        self.taskTimeout = 20;
        self.serverAddress = kNetworkAPIServer;
        self.afManager = [AFHTTPSessionManager manager];
    
        [_afManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [_afManager.requestSerializer setHTTPMethodsEncodingParametersInURI:[NSSet setWithObjects:@"GET",@"DELETE",nil]];
        [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    
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
    
    if(resultObj.statusCode != nil && NetStatusCodeSuc([resultObj.statusCode integerValue])) {
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultSuccessBack:forInfo:)]) {
            [delegate netResultSuccessBack:resultObj forInfo:customInfo];
        }
    } else if(resultObj.statusCode != nil && NetStatusCodeFail([resultObj.statusCode integerValue])) {
        
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            [delegate netResultFailBack:resultObj.statusDesc errorCode:[resultObj.statusCode integerValue]  forInfo:customInfo];
        }
    }
}

//
- (void)handleHTTPError:(NSError *)error
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

    __weak NetworkTask *weakSelf = self;
    [_afManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",_serverAddress,api];
    if([method isEqualToString:@"POST"]) {
        
        [_afManager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            //
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //
            RESPONSE_LOG
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            [weakSelf handleHTTPError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
    }
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
@end
