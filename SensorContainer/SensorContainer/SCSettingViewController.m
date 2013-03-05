//
//  SCSettingViewController.m
//  SensorContainer
//
//  Created by Jack Wu on 13-02-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "SCSettingViewController.h"
#import <UIKit/UIKit.h>

@interface SCSettingViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *serverURLTextField;
@end

static SCSettingViewController *viewController = nil;

@implementation SCSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    viewController = [super initWithStyle:style];
    if (self) {
        self.serverURLTextField = [[UITextField alloc] init];
        self.serverURLTextField.delegate = self;
        self.serverURLTextField.placeholder = @"Server URL";
        self.serverURLTextField.text = @"http://kimberly.magic.ubc.ca:8080/thingbroker";
    }
    return viewController;
}

+(NSString *) serverURL {
    if(!viewController.serverURLTextField) {
        return nil;
    }
    
    return viewController.serverURLTextField.text;
}

#pragma mark UIViewController
- (void)viewWillLayoutSubviews {
    self.serverURLTextField.frame = CGRectMake(self.serverURLTextField.superview.frame.origin.x + 10, self.serverURLTextField.superview.frame.origin.y + 10, self.serverURLTextField.superview.frame.size.width - 40, self.serverURLTextField.superview.frame.size.height - 10);
}


#pragma mark UITableViewDataSourceDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // allocate cell, reusing if possible
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // add text field in table cell
    self.serverURLTextField.frame = CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y + 10, cell.frame.size.width - 40, cell.frame.size.height - 10);
    [cell.contentView addSubview:self.serverURLTextField];
    
    // configure cell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
 
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"ThingBroker";
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];    
    return YES;
}

@end
