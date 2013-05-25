//
//  MBProgressHUD+Utility.m
//  SensorContainer
//
//  Created by Jack Wu on 13-03-06.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "MBProgressHUD+Utility.h"
#import "SCAppDelegate.h"


@implementation MBProgressHUD (Utility)

+ (MBProgressHUD *)showLoadingWithHUD:(MBProgressHUD *)hud AndText:(NSString *)text
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
	hud = [[MBProgressHUD alloc] initWithView:vc.view];
    
	[vc.view addSubview:hud];
    
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = text;
    hud.userInteractionEnabled = NO;
	
	[hud show:YES];
    
    return hud;
}

+ (void)showCompleteWithText:(NSString *)text
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:vc.view];    
    
	[vc.view addSubview:hud];
    
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.labelText = text;
    hud.userInteractionEnabled = NO;
	
	[hud show:YES];
	[hud hide:YES afterDelay:1.5];
}

+ (void)showWarningWithText:(NSString *)text
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:vc.view];
    
	[vc.view addSubview:hud];
    
	hud.mode = MBProgressHUDModeCustomView;
	hud.labelText = text;
    hud.userInteractionEnabled = NO;
	
	[hud show:YES];
	[hud hide:YES afterDelay:1.5];
}


+ (void)showText:(NSString *)text
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = text;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
	
	[hud hide:YES afterDelay:1.5];
}

@end
