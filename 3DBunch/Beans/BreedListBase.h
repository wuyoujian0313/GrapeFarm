//
//  BreedListBase.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/5/17.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "NetResultBase.h"
#import "GrapeBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface BreedListBase : NetResultBase
@property(nonatomic, strong, getter=getBreedList) NSArray *kBaiduParserArray(breeds,GrapeBean);
@end

NS_ASSUME_NONNULL_END
