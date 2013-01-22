//
//  AppDelegate.m
//  iOSContainer
//
//  Created by Jack Wu on 13-01-13.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import "SCAppDelegate.h"
#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "SCRootViewController.h"


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
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	
	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
    
	NSArray *headers = @[
    [NSNull null],
    @"ACTIVITIES",
    @"SETTINGS"
	];
	NSArray *controllers = @[
    @[
    [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]],
    ],
    @[
    [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]],
    [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]],
    [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]]
    ],
    @[
    [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]]
    ]
	];
        
	NSArray *cellInfos = @[
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"Browser", @"")},
    ],
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"Accelerometer", @"")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"Photo", @"")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"QR", @"")}
    ],
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"About", @"")}
    ]
	];
	
	// Add drag feature to each root navigation controller
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                 action:@selector(dragContentView:)];
    panGesture.cancelsTouchesInView = NO;
	[controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
			((UINavigationController *)obj2).navigationBar.tintColor = [UIColor colorWithRed:(38.0f/255.0f) green:(44.0f/255.0f) blue:(58.0f/255.0f) alpha:1.0f];
			[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
        }];
	}];

	
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
