//
//  SaveSimpleDataManager.h
//  GrapeFarm
//
//  Created by Wu YouJian on 2019/4/3.
//  Copyright © 2019 Wu YouJian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SaveSimpleDataManager : NSObject

- (void)setObject:(id)value forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
