//
//  NetworkTask.h
//  CommonProject
//
//  Created by wuyoujian on 16/7/4.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AICommonDef.h"


typedef NS_ENUM(NSInteger, NetStatusCode) {
    NetStatusCodeSuccess = 1,
    NetStatusCodePasswordError = 2,
    NetStatusCodeEmailExist = 3,
    NetStatusCodeEmailCodeUnExist = 4,
    NetStatusCodeEmailCodeError = 5,
    NetStatusCodeEmailCodeExpired = 6,
    NetStatusCodeUnknown=INT_MAX,
};


#define NetStatusCodeSuc(status)    (status == NetStatusCodeSuccess)
#define NetStatusCodeFail(status)   (status != NetStatusCodeSuccess)


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
// POST
- (void)startPOSTTaskApi:(NSString*_Nonnull)api
                forParam:(NSDictionary *_Nonnull)param
                delegate:(id <NetworkTaskDelegate>_Nonnull)delegate
               resultObj:(NetResultBase*_Nonnull)resultObj
              customInfo:(id _Nonnull)customInfo;

// GET
- (void)startGETTaskApi:(NSString*)api
               forParam:(NSDictionary *)param
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:(NetResultBase*)resultObj
             customInfo:(id)customInfo;


@end
