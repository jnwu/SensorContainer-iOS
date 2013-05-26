//
//  SCSettingViewController.h
//  SensorContainer
//
//  Created by Jack Wu on 13-02-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//


/*
        The SCSettingViewController shows the currently set url for the thingbroker and web application container.
 */

@interface SCSettingViewController : UITableViewController
+ (NSString *)serverURL;
+ (NSString *)clientURL;
@end
