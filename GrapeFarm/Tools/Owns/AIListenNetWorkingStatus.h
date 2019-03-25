//
//  AIListenNetWorkingStatus.h
//  CommonProject
//
//  Created by Wu YouJian on 2018/11/20.
//

#import <Foundation/Foundation.h>
#import "AICommonDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIListenNetWorkingStatus : NSObject

AISINGLETON_CLASS_DEF(AIListenNetWorkingStatus, sharedNetListener)
- (void)listen;
@end

NS_ASSUME_NONNULL_END
