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
#import "SCQRViewController.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>

#pragma mark -
#pragma mark Private Interface
@interface SCAppDelegate () <RKRequestDelegate>
@property (nonatomic, strong) GHMenuViewController *menuController;
@property (nonatomic, strong) NSMutableArray *apps;
@property (nonatomic, strong) NSMutableArray *links;
@end


#pragma mark -
#pragma mark Implementation
@implementation SCAppDelegate

#pragma mark Properties

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // disable restkit logging
    RKLogConfigureByName("*", RKLogLevelOff);

    // get app list
    RKClient *client = [RKClient clientWithBaseURL:[RKURL URLWithBaseURLString:@"http://container.icd.magic.ubc.ca/api/apps"]];
    RKRequest *request = [client get:@"/" queryParameters:nil delegate:self];
    [request sendSynchronously];
    
    [self setupSidbarAndViewControllers];
    return YES;
}

- (void)setupSidbarAndViewControllers {
 	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];    
	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
    
    // add header subsections in menu sidebar
	NSArray *headers = @[@"APPS", @"SETTINGS"];
    UINavigationController *settingController = [[UINavigationController alloc] initWithRootViewController:[[SCSettingViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    UINavigationController *qrController = [[UINavigationController alloc] initWithRootViewController:[[SCQRViewController alloc] init]];
    
    // add apps and links for menu sidebar    
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for(int i=0 ; i<[self.apps count] ; i++) {
        [cells addObject:@{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"],
                            kSidebarCellTextKey: NSLocalizedString([self.apps objectAtIndex:i], @"")}];
    }
    
    NSMutableArray *cellNavs = [[NSMutableArray alloc] init];
    for(int i=0 ; i<[self.links count] ; i++) {
        [cellNavs addObject:[[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] initWithURL:[self.links objectAtIndex:i]]]];
    }
    
	NSArray *controllers = @[cellNavs, @[settingController, qrController]];
	NSArray *cellInfos = @[ cells, @[
                                        @{ kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"],
                                            kSidebarCellTextKey: NSLocalizedString(@"Broker URL", @"")},
                                        @{ kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"],
                                           kSidebarCellTextKey: NSLocalizedString(@"Scan Display", @"")}                                        
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
}


#pragma mark RKRequestDelegate
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    self.apps = [[NSMutableArray alloc] init];
    self.links = [[NSMutableArray alloc] init];
    
    // chop json string into separate json objects
    NSString *body = [response bodyAsString];
    body = [body substringWithRange:NSMakeRange(1, [body length]-1)];
    body = [body substringWithRange:NSMakeRange(0, [body length]-1)];

    NSRange range = [body rangeOfString:@"}"];
    while((range.location) < [body length]) {
        if([[body substringWithRange:NSMakeRange(0, 1)] isEqualToString:@","]) {
            body = [body substringWithRange:NSMakeRange(1, [body length]-1)];
        }
    
        // convert next json object in array
        range = [body rangeOfString:@"}"];
        NSString *jsonString = [body substringWithRange:NSMakeRange(0, range.location+1)];
        NSDictionary *jsonDict = [NSJSONSerialization   JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options: NSJSONReadingMutableContainers
                                                                     error: nil];
        
        // 2 - name
        // 6 - link
        // append apps info
        NSArray *values = [jsonDict allValues];
        [self.apps addObject:[values objectAtIndex:2]];
        [self.links addObject:[values objectAtIndex:6]];

        // move cursor to next json object
        body = [body substringWithRange:NSMakeRange(range.location+1, [body length]-range.location-1)];
        range.location = 0;
    }
}

@end