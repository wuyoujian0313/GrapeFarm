//
//  GoodsBean.h
//  3DBunch
//
//  Created by Wu YouJian on 2019/10/8.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoodsBean : NSObject
@property(nonatomic,strong)NSNumber     *id;
@property(nonatomic,copy)NSString       *name;
@property(nonatomic,strong)NSNumber     *amount;
@property(nonatomic,strong)NSNumber     *type;

@end

NS_ASSUME_NONNULL_END
