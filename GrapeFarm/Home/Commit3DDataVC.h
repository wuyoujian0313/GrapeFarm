//
//  Commit3DDataVC.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/28.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Commit3DDataVC : BaseVC
@property (nonatomic, assign) CGFloat max_r;
@property (nonatomic, assign) CGFloat mix_r;
@property (nonatomic, strong) NSArray *circles;
@property (nonatomic, copy)NSString *modelString;
@end

NS_ASSUME_NONNULL_END
