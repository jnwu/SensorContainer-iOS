//
//  SCSettingViewController.m
//  SensorContainer
//
//  Created by Jack Wu on 13-02-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCSettingViewController.h"
#import "SCAppDelegate.h"
#import "STThing.h"

@interface SCSettingViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *thingBrokerUrlTextField;
@property (nonatomic, strong) UITextField *containerUrlTextField;
@end

static SCSettingViewController *viewController = nil;
static NSString *kThingBrokerTextFieldPlaceholder = @"ThingBroker URL";
static NSString *kContainerTextFieldPlaceholder = @"Container URL";

@implementation SCSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    viewController = [super initWithStyle:style];
    if (viewController)
    {
        viewController.thingBrokerUrlTextField = [[UITextField alloc] init];
        viewController.thingBrokerUrlTextField.delegate = self;
        viewController.thingBrokerUrlTextField.placeholder = kThingBrokerTextFieldPlaceholder;
        viewController.thingBrokerUrlTextField.text = [STThing thingBrokerUrl];
        
        viewController.containerUrlTextField = [[UITextField alloc] init];
        viewController.containerUrlTextField.delegate = self;
        viewController.containerUrlTextField.placeholder = kContainerTextFieldPlaceholder;
        viewController.containerUrlTextField.text = [STThing containerUrl];
    }
    return viewController;
}

+(NSString *) serverURL
{
    if(!viewController.thingBrokerUrlTextField)
    {
        return nil;
    }
    
    return viewController.thingBrokerUrlTextField.text;
}

+(NSString *) clientURL
{
    if(!viewController.containerUrlTextField)
    {
        return nil;
    }
    
    return viewController.containerUrlTextField.text;
}


#pragma mark UIViewController
- (void)viewWillLayoutSubviews
{
    self.thingBrokerUrlTextField.frame = CGRectMake(self.thingBrokerUrlTextField.superview.frame.origin.x + 10, self.thingBrokerUrlTextField.superview.frame.origin.y + 10, self.thingBrokerUrlTextField.superview.frame.size.width - 40, self.thingBrokerUrlTextField.superview.frame.size.height - 10);
    self.containerUrlTextField.frame = CGRectMake(self.containerUrlTextField.superview.frame.origin.x + 10, self.containerUrlTextField.superview.frame.origin.y + 10, self.containerUrlTextField.superview.frame.size.width - 40, self.containerUrlTextField.superview.frame.size.height - 10);
}


#pragma mark UITableViewDataSourceDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // add text field in table cell
        self.thingBrokerUrlTextField.frame = CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y + 10, cell.frame.size.width - 40, cell.frame.size.height - 10);
        [cell.contentView addSubview:self.thingBrokerUrlTextField];
        
        // configure cell
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if(indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // add text field in table cell
        self.containerUrlTextField.frame = CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y + 10, cell.frame.size.width - 40, cell.frame.size.height - 10);
        [cell.contentView addSubview:self.containerUrlTextField];
        
        // configure cell
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
        return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return @"ThingBroker Server";
    
        case 1:
            return @"Web Application Container";
    }
    
    return nil;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.placeholder isEqualToString:kThingBrokerTextFieldPlaceholder])
    {
        [STThing setThingBrokerUrl:textField.text];
    }
    else if([textField.placeholder isEqualToString:kContainerTextFieldPlaceholder])
    {
        [STThing setContainerUrl:textField.text];
        
        // Update application list
        SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate applicationList];
        [appDelegate setupSidbarAndViewControllers];
    }
    
    [textField resignFirstResponder];
    return YES;
}

@end