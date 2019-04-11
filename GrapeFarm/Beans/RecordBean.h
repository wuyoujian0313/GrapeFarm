//
//  RecordBean.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/11.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordBean : NSObject
@property(nonatomic,copy)NSString       *farmName;
@property(nonatomic,copy)NSString       *grapeName;
@property(nonatomic,copy)NSString       *modelData;
@property(nonatomic,copy)NSString       *timestamp;
@property(nonatomic,strong)NSNumber     *latitude;
@property(nonatomic,strong)NSNumber     *longitude;
@end

NS_ASSUME_NONNULL_END
