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
        self.taskTimeout = 30;
        self.serverAddress = kNetworkAPIServer;
        self.afManager = [AFHTTPSessionManager manager];
    
        [_afManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [_afManager.requestSerializer setHTTPMethodsEncodingParametersInURI:[NSSet setWithObjects:@"GET",@"DELETE",nil]];
        [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
        [_afManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
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
        
        NSString *errorDesc = [self errerDescription:[resultObj.statusCode integerValue]];
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            [delegate netResultFailBack:errorDesc errorCode:[resultObj.statusCode integerValue]  forInfo:customInfo];
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
    
    // 统一增加token字段
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:kLoginTokenUserdefaultKey];
    if ((token != nil && [token length] > 0) &&
        ![api isEqualToString:kAPIRegiterUser] &&
        ![api isEqualToString:kAPIGetRegiterCode] &&
        ![api isEqualToString:kAPIResetPassword] &&
        ![api isEqualToString:kAPILogin]) {
        [_afManager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    __weak NetworkTask *weakSelf = self;
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
    } else if ([method isEqualToString:@"GET"]) {
        
        [_afManager GET:urlString parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
            //
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            RESPONSE_LOG
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf handleHTTPError:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
        
    }
}

- (NSString *)errerDescription:(NSInteger)statusCode {
    NSMutableString *desc = [[NSMutableString alloc] initWithCapacity:0];
    
    switch (statusCode) {
        case NetStatusCodeSuccess: {
            [desc appendString:NSLocalizedString(@"Successful", nil)];
            break;
        }

        case NetStatusCodeEmailExist: {
            [desc appendString:NSLocalizedString(@"NetStatusCodeEmailExist", nil)];
            break;
        }
            
        case NetStatusCodeEmailCodeUnExist:{
            [desc appendString:NSLocalizedString(@"NetStatusCodeEmailCodeUnExist", nil)];
            break;
        }
            
        case NetStatusCodeEmailCodeExpired: {
            [desc appendString:NSLocalizedString(@"NetStatusCodeEmailCodeExpired", nil)];
            break;
        }
            
        case NetStatusCodeEmailCodeError: {
            [desc appendString:NSLocalizedString(@"NetStatusCodeEmailCodeError", nil)];
            break;
        }
        case NetStatusCodePasswordError:{
            [desc appendString:NSLocalizedString(@"NetStatusCodePasswordError", nil)];
            break;
        }
            
        default:
            [desc appendString:NSLocalizedString(@"NetStatusCodeUnknown", nil)];
            break;
    }
    
    return desc;
}
@end
