//
//  AIListenNetWorkingStatus.m
//  CommonProject
//
//  Created by Wu YouJian on 2018/11/20.
//

#import "AIListenNetWorkingStatus.h"
#import "Reachability.h"
#import "FadePromptView.h"

@interface  AIListenNetWorkingStatus ()
@property (nonatomic,strong) Reachability *hostReachability;
@property (nonatomic,strong) Reachability *internetReachability;
@end

@implementation AIListenNetWorkingStatus

AISINGLETON_CLASS_IMP(AIListenNetWorkingStatus, sharedNetListener)

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initListener];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)initListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    // 设置网络检测的站点
    NSString *remoteHostName = @"www.baidu.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
}

- (void)listen {
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case 0:
            NSLog(@"Not Reachable");
            [FadePromptView showPromptStatus:@"手机已断开网络，请检查" duration:1.5 finishBlock:nil];
            break;
        case 1:
            NSLog(@"ReachableViaWiFi----WIFI");
            break;
        case 2:
            NSLog(@"ReachableViaWWAN----蜂窝网络");
            break;
            
        default:
            break;
    }
}



@end
