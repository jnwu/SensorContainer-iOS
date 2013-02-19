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
#import "STThing.h"

#import <RestKit/RestKit.h>

#pragma mark -
#pragma mark Private Interface
@interface SCAppDelegate () <RKRequestDelegate, RKObjectLoaderDelegate>
@property (nonatomic, strong) GHMenuViewController *menuController;
@end


#pragma mark -
#pragma mark Implementation
@implementation SCAppDelegate

#pragma mark Properties

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[self sendRequestWithParams];
    
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
    
	NSArray *headers = @[
    @"APPS",
    @"SETTINGS"
	];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]];
    
	NSArray *controllers = @[
    @[navigationController, navigationController, navigationController],
    @[navigationController, navigationController, navigationController],
    @[
    [[UINavigationController alloc] initWithRootViewController:[[SCRootViewController alloc] init]]
    ]
	];
        
	NSArray *cellInfos = @[
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"CoffeeHouse", @"")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"PubCrawl", @"")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"MallHop", @"")}
    ],
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"32-iphone.png"], kSidebarCellTextKey: NSLocalizedString(@"About", @"")}
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


- (void)sendRequestWithParams {
    RKLogConfigureByName("*", RKLogLevelOff);

    
    
    // Simple params
    RKURL *baseURL = [RKURL URLWithBaseURLString:@"http://kimberly.magic.ubc.ca:8080/thingbroker"];
    RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];
    
    objectManager.acceptMIMEType = RKMIMETypeJSON;
    objectManager.serializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping *thingMapping = [RKObjectMapping mappingForClass:[STThing class]];
    [thingMapping mapKeyPath:@"thingId" toAttribute:@"thingId"];
    [thingMapping mapKeyPath:@"description" toAttribute:@"description"];
    [thingMapping mapKeyPath:@"name" toAttribute:@"name"];
    [thingMapping mapKeyPath:@"type" toAttribute:@"type"];
    
    [objectManager.mappingProvider registerObjectMapping:thingMapping withRootKeyPath:@""];
    
    // set rest param
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:@"123", @"thingId", nil];
    RKURL *resourceURL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/thing/search" queryParameters:queryParams];
    
    // send get request
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [resourceURL resourcePath], [resourceURL query]] delegate:self];
}



- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {    
    if ([response isSuccessful]) {
        // Looks like we have a 201 response of type 'application/json'
        //NSLog(@"%@", [response bodyAsString]);
    } else if ([response isError]) {
        // Response status was either 400..499 or 500..599
        //NSLog(@"Ouch! We have an HTTP error. Status Code description: %@", [response localizedStatusCodeString]);
    }
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSArray *components = [objectLoader.resourcePath componentsSeparatedByString:@"?"];
    if ([(NSString *)components[0] compare:@"/thing/search"] == 0) {
        STThing *thing = (STThing *) objects[0];
        
        NSLog(@"thing: %@", thing.name);
        NSLog(@"size: %i", [objects count]);
    }
}


@end











