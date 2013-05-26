//
//  SCAppDelegate.h
//  SensorContainer
//
//  Created by Daniel Yuen on 13-01-10.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "GHRevealViewController.h"

@interface SCAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) GHRevealViewController *revealController;

/*
    a list of applications is returned from the web application container, where it is populated in the ghsidebarnav
 */
- (void)applicationList;


/*
    in the ghsidebarnav, each application has its own webview, where the url provided by the web application container is opened
 */
- (void)setupSidbarAndViewControllers;

@end
