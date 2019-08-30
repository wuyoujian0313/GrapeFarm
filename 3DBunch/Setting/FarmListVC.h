//
//  FarmListVC.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FarmSelectIndexDelegate <NSObject>
- (void)didSelectedFarmName:(NSString *)farmName;
@end

@interface FarmListVC : BaseVC
@property (nonatomic, weak)id<FarmSelectIndexDelegate> delegate;
- (void)setFarmName:(nullable NSString *)farmName saveToConfig:(BOOL)isSave;
@end

NS_ASSUME_NONNULL_END
