//
//  FarmListBean.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/5/17.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"
#import "FarmBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface FarmListBean : NetResultBase
@property(nonatomic, strong, getter=getFarmList) NSArray *kBaiduParserArray(farms,FarmBean);
@end

NS_ASSUME_NONNULL_END
