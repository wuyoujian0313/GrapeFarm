//
//  LoginBean.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/26.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginBean : NetResultBase
@property (nonatomic,copy) NSString *token;
@end

NS_ASSUME_NONNULL_END
