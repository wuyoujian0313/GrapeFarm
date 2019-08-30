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
@property(nonatomic, strong, getter=getRecordList) NSArray *kBaiduParserArray(content,RecordBean);
@property(nonatomic, strong)NSNumber *empty;
@property(nonatomic, strong)NSNumber *first;
@property(nonatomic, strong)NSNumber *last;
@property(nonatomic, strong)NSNumber *number;
@property(nonatomic, strong)NSNumber *numberOfElements;
@property(nonatomic, strong)NSNumber *size;
@property(nonatomic, strong)NSNumber *totalElements;
@property(nonatomic, strong)NSNumber *totalPages;

@end

NS_ASSUME_NONNULL_END
