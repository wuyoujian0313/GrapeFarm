//
//  VIPUserBean.h
//  3DBunch
//
//  Created by Wu YouJian on 2019/12/13.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface VIPUserBean : NetResultBase
@property(nonatomic,strong)NSNumber     *id;
@property(nonatomic,copy)NSString       *email;
@property(nonatomic,copy)NSString       *startDate;
@property(nonatomic,copy)NSString       *endDate;
@property(nonatomic,strong)NSNumber     *type;
@property(nonatomic,copy)NSString       *transactionId;
@end

NS_ASSUME_NONNULL_END
