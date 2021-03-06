//
//  MBProgressHUD+Utility.h
//  SensorContainer
//
//  Created by Jack Wu on 13-03-06.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Utility)

+ (MBProgressHUD *)showLoadingWithHUD:(MBProgressHUD *)hud AndText:(NSString *)text;
+ (void)showCompleteWithText:(NSString *)text;
+ (void)showWarningWithText:(NSString *)text;
+ (void)showText:(NSString *)text;

@end
