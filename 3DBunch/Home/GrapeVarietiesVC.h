//
//  GrapeVarietiesVC.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/3/27.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN
@protocol GrapeVarietiesSelectIndexDelegate <NSObject>
- (void)didSelectedGrapeVariety:(NSString *)variety;
@end

@interface GrapeVarietiesVC : BaseVC
@property (nonatomic,weak) id<GrapeVarietiesSelectIndexDelegate> delegate;
- (void)setGrapeVariety:(NSString *)variety;
@end

NS_ASSUME_NONNULL_END
