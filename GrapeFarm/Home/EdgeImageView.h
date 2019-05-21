//
//  EdgeImageView.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/29.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface EdgeImageView : UIImageView
- (void)setPenColor:(UIColor *)color;
- (void)setCircles:(NSArray *)circles;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
