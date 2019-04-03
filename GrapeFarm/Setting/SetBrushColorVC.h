//
//  SetBrushColorVC.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/3.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ColorSelectIndexDelegate <NSObject>
- (void)didSelectedColorValue:(NSInteger)color colorName:(NSString *)colorName;
@end

@interface SetBrushColorVC : BaseVC
@property (nonatomic, weak)id<ColorSelectIndexDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
