//
//  GHRootViewController.m
//  iOSContainer
//
//  Created by Jack Wu on 13-01-13.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import "SCRootViewController.h"
#import "STCSensorFactory.h"
#import "STCSensorConfig.h"
#import "CameraSensor.h"
#import "QRCodeSensor.h"

@interface SCRootViewController () <UIWebViewDelegate, UITextFieldDelegate, CameraSensorDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) STSensor *sensor;
@end


@implementation SCRootViewController


- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        /*
         self.navigationItem.leftBarButtonItem =
         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
         target:self
         action:@selector(revealSidebar)];
         */
        /*
         self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"259-list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(revealSidebar)];
         
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
         target:self
         action:@selector(showActionSheet)];
         */
        
    }
	
    return self;
}


- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post to Thing Broker", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"clicked: %i", buttonIndex);
    
}

#pragma mark SCRootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // add text field for web view
    CGFloat width = self.view.frame.size.width;
    self.textField = [[UITextField alloc] initWithFrame:
                      CGRectMake(10,9,width-20,26)];
    
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.font = [UIFont systemFontOfSize:17];
    
    
    self.textField.placeholder = @"Go to this address";
    self.textField.textColor = [UIColor blackColor];
    self.textField.font = [UIFont systemFontOfSize:14.0f];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [self.textField setDelegate:self];
    [self.navigationController.navigationBar addSubview:self.textField];
    
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view.backgroundColor = [UIColor whiteColor];
    
    // add web view
	NSString *urlAddress = @"http://www.google.com";
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
}

- (void)viewDidAppear:(BOOL)animated {
    /*
    NSString * cmd = @"http://bridge.sensetecnic.com/camera";
    self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
    self.sensor.delegate = self;
    [self.sensor start];
    NSString * cmd = @"http://bridge.sensetecnic.com/qrcode";
    self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
    self.sensor.delegate = self;
    [self.sensor start];
    [self.sensor cancel];
     */
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    textField.textColor = [UIColor grayColor];
	NSURL *url = [NSURL URLWithString:textField.text];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
    
    return NO;
}


#pragma STSensorDelegate
-(void) STSensor: (STSensor *) sensor1 withData: (STSensorData *) data
{
    NSLog(@"sensor got data?");
    //Handling data from sensor
    //TODO: use sensor factory to create sensor data handler class
    // but nothing is implemented right now.
    if([sensor1 isKindOfClass: [CameraSensor class]])
    {
        
        NSLog(@"camera data");
        //UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];
        //[self.imageView setImage:image];
    }
    else if([sensor1 isKindOfClass: [QRCodeSensor class]])
    {
    }
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{
    NSLog(@"sensor got error");
}

-(void) STSensorCancelled: (STSensor *) sensor
{
    NSLog(@"sensor cancelled");
}

@end
