//
//  ZYGameFB.h
//  ZYWebGameKitSample
//
//  Created by admin on 2020/5/12.
//  Copyright © 2020 Octopus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYGameFB : NSObject
+ (instancetype)shareFacebook;
- (void)initWithAppID:(NSString *)AppID application:(UIApplication *)application options:(NSDictionary *)launchOptions;
@end

NS_ASSUME_NONNULL_END
