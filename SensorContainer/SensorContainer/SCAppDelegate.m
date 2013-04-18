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
#import "STThing.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>

#pragma mark -
#pragma mark Private Interface
@interface SCAppDelegate () <RKRequestDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) GHMenuViewController *menuController;
@property (nonatomic, strong) NSMutableArray *apps;
@property (nonatomic, strong) NSMutableArray *links;
@property (nonatomic, strong) UIAlertView *alert;
@end

#pragma mark -
#pragma mark Implementation
@implementation SCAppDelegate

#pragma mark Properties
#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.alert = nil;
    
    // disable restkit logging
    RKLogConfigureByName("*", RKLogLevelOff);

    [self applicationList];
    [self setupSidbarAndViewControllers];
    
    return YES;
}

- (void)applicationList
{
    // get app list
    RKClient *client = [RKClient clientWithBaseURL:[RKURL URLWithBaseURLString:[STThing containerUrl]]];
    RKRequest *request = [client get:@"/" queryParameters:nil delegate:self];
    [request sendSynchronously];
    
}

- (void)setupSidbarAndViewControllers
{
    NSArray *headers = nil;
    NSArray *controllers = nil;
    NSArray *cellInfos = nil;
    
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    NSMutableArray *cellNavs = [[NSMutableArray alloc] init];

	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
    UINavigationController *qrController = [[UINavigationController alloc] initWithRootViewController:[[SCQRViewController alloc] init]];
    UINavigationController *settingController = [[UINavigationController alloc] initWithRootViewController:[[SCSettingViewController alloc]initWithStyle:UITableViewStyleGrouped]];

 	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;

    // only show settings if no apps found in large container
    if((!self.apps || [self.apps count] == 0) || (!self.links || [self.links count] == 0))
    {
        headers = @[@"SETTINGS"];
        controllers = @[@[settingController, qrController]];
        cellInfos = @[@[
                          @{kSidebarCellImageKey:[UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey:NSLocalizedString(@"Broker URL", @"")},
                          @{kSidebarCellImageKey:[UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey:NSLocalizedString(@"Scan Display", @"")}]
                    ];
        
        self.alert = [[UIAlertView alloc] initWithTitle:nil
                                                message:@"No apps found in cherry container, please restart app when apps have been added"
                                               delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil, nil];
        [self.alert show];
    }
    else
    {
        headers = @[@"APPS", @"SETTINGS"];

        // add apps and links for menu sidebar
        for(int i=0 ; i<[self.apps count] ; i++)
        {
            [cells addObject:@{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString([self.apps objectAtIndex:i], @"")}];
        }
        
        for(int i=0 ; i<[self.links count] ; i++)
        {
            [cellNavs addObject:[[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] initWithURL:[self.links objectAtIndex:i]]]];
        }

        controllers = @[cellNavs, @[settingController, qrController]];
        cellInfos = @[cells,
                      @[
                        @{kSidebarCellImageKey:[UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey:NSLocalizedString(@"URL", @"")},
                        @{kSidebarCellImageKey:[UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey:NSLocalizedString(@"Scan Display", @"")}]
                    ];
    }
    
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
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    self.apps = [[NSMutableArray alloc] init];
    self.links = [[NSMutableArray alloc] init];
    
    NSString *body = [response bodyAsString];

    // stop JSON parsing if error no json object found in response
    if(![NSJSONSerialization   JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding]
                                          options:NSJSONReadingMutableContainers
                                            error:nil])
        return;

    // chop json string into separate json objects
    body = [body substringWithRange:NSMakeRange(1, [body length]-1)];
    body = [body substringWithRange:NSMakeRange(0, [body length]-1)];

    NSRange range = [body rangeOfString:@"}"];
    while((range.location) < [body length])
    {
        if([[body substringWithRange:NSMakeRange(0, 1)] isEqualToString:@","])
            body = [body substringWithRange:NSMakeRange(1, [body length]-1)];
    
        // convert next json object in array
        range = [body rangeOfString:@"}"];
        NSString *jsonString = [body substringWithRange:NSMakeRange(0, range.location+1)];
        
        NSDictionary *jsonDict = [NSJSONSerialization   JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];

        if([[jsonDict objectForKey:@"mobile_url"] length] == 0)
            [self.links addObject:[jsonDict objectForKey:@"url"]];
        else
            [self.links addObject:[jsonDict objectForKey:@"mobile_url"]];

        [self.apps addObject:[jsonDict objectForKey:@"name"]];
        
        // move cursor to next json object
        body = [body substringWithRange:NSMakeRange(range.location+1, [body length]-range.location-1)];
        range.location = 0;
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{}

@end