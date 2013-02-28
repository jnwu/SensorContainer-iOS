//
//  SCAppDelegate.m
//  iOSContainer
//
//  Created by Jack Wu on 13-01-13.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import "SCAppDelegate.h"
#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "SCRootViewController.h"
#import "SCSettingViewController.h"
#import "STThing.h"

#import <RestKit/RestKit.h>

#pragma mark -
#pragma mark Private Interface
@interface SCAppDelegate ()
@property (nonatomic, strong) GHMenuViewController *menuController;
@end


#pragma mark -
#pragma mark Implementation
@implementation SCAppDelegate

#pragma mark Properties

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // disable restkit logging
    RKLogConfigureByName("*", RKLogLevelOff);

    //
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
    
	NSArray *headers = @[
    @"APPS",
    @"SETTINGS"
	];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]];
    UINavigationController *settingController = [[UINavigationController alloc] initWithRootViewController:[[SCSettingViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    
	NSArray *controllers = @[
    @[navigationController, navigationController, navigationController],
    @[settingController]
	];
        
	NSArray *cellInfos = @[
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"CoffeeHouse", @"")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"PubCrawl", @"")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"MallHop", @"")}
    ],
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"ThingBroker", @"")}
    ]
	];
	
    // Hide navigation bar
	[controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
			[((UINavigationController *)obj2).navigationBar setHidden:YES];
        }];
	}];

    // Add pan gesture to webview
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                 action:@selector(dragContentView:)];
    panGesture.cancelsTouchesInView = NO;	
    [self.revealController.view addGestureRecognizer:panGesture];	
	self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
																		withSearchBar:nil
																		  withHeaders:headers
																	  withControllers:controllers
																		withCellInfos:cellInfos];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end











