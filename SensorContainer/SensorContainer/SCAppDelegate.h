//
//  SCAppDelegate.h
//  SensorContainer
//
//  Created by Daniel Yuen on 13-01-10.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRevealViewController.h"

@interface SCAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) GHRevealViewController *revealController;
@end
