//
//  AppDelegate.m
//  iOSContainer
//
//  Created by Jack Wu on 13-01-13.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import "GHMenuCell.h"
#import "GHMenuViewController.h"
//#import "GHSidebarSearchViewController.h"
//#import "GHSidebarSearchViewControllerDelegate.h"
#import "SCAppDelegate.h"
#import "SCRootViewController.h"


#pragma mark -
#pragma mark Private Interface
@interface SCAppDelegate () /*<GHSidebarSearchViewControllerDelegate>*/
//@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
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
	
/*
	RevealBlock revealBlock = ^(){
		[self.revealController toggleSidebar:!self.revealController.sidebarShowing
									duration:kGHRevealSidebarDefaultAnimationDuration];
	};
*/
    
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
    
	//self.searchController = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self.revealController];
/*
	self.searchController.view.backgroundColor = [UIColor clearColor];
    self.searchController.searchDelegate = self;
	self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchController.searchBar.backgroundImage = [UIImage imageNamed:@"searchBarBG.png"];
	self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", @"");
	self.searchController.searchBar.tintColor = [UIColor colorWithRed:(58.0f/255.0f) green:(67.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
	for (UIView *subview in self.searchController.searchBar.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
			UITextField *searchTextField = (UITextField *) subview;
			searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
		}
	}
	[self.searchController.searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searchTextBG.png"]
                                                                    resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)]
														  forState:UIControlStateNormal];
	[self.searchController.searchBar setImage:[UIImage imageNamed:@"searchBarIcon.png"]
							 forSearchBarIcon:UISearchBarIconSearch
										state:UIControlStateNormal];
*/
	
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

/*
#pragma mark GHSidebarSearchViewControllerDelegate
- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback {
	callback(@[@"Foo", @"Bar", @"Baz"]);
}

- (void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Selected Search Result - result: %@ indexPath: %@", result, indexPath);
}

- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	static NSString* identifier = @"GHSearchMenuCell";
	GHMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.textLabel.text = (NSString *)entry;
	cell.imageView.image = [UIImage imageNamed:@"user"];
	return cell;
}
*/

@end
