//
//  GoodsListBean.h
//  3DBunch
//
//  Created by Wu YouJian on 2019/12/11.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"
#import "GoodsBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoodsListBean : NetResultBase
@property(nonatomic, strong, getter=getGoodsList) NSArray *kBaiduParserArray(goods,GoodsBean);
@end

NS_ASSUME_NONNULL_END
