//
//  RecordListBean.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/11.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"
#import "RecordBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordListBean : NetResultBase
@property(nonatomic, strong, getter=getRecordList) NSArray *kBaiduParserArray(records,RecordBean);
@property(nonatomic, strong)NSNumber *count;
@property(nonatomic, strong)NSNumber *sum;
@end

NS_ASSUME_NONNULL_END
