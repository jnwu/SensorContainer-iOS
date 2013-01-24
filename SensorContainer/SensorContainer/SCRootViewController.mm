//
//  SCRootViewController.m
//  SensorContainer
//
//  Created by Jack Wu on 13-01-13.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import "SCRootViewController.h"
#import "STCSensorFactory.h"
#import "STCSensorConfig.h"
#import "CameraSensor.h"
#import "QRCodeSensor.h"
#import "AccelerometerSensor.h"

@interface SCRootViewController () <UIWebViewDelegate, CameraSensorDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) STSensor *sensor;
@end


@implementation SCRootViewController

#pragma SCRootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view.backgroundColor = [UIColor whiteColor];
    
    // add webview
	NSString *urlAddress = @"http://jnwuserver.appspot.com/";
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
}


#pragma UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"inapp"]) {
        
        if ([request.URL.host isEqualToString:@"camera"]) {            
            NSString * cmd = @"http://bridge.sensetecnic.com/camera";
            self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
            self.sensor.delegate = self;
            [self.sensor start];
        }

        if ([request.URL.host isEqualToString:@"qr"]) {
            NSString * cmd = @"http://bridge.sensetecnic.com/qrcode";
            self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
            self.sensor.delegate = self;
            [self.sensor start];
            [self.sensor cancel];
        }
        
        if ([request.URL.host isEqualToString:@"accelerometer"]) {
            NSString * cmd = @"http://bridge.sensetecnic.com/accelerometer";
            self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
            self.sensor.delegate = self;
            [self.sensor start];
        }

        return NO;
    }
    return YES;
}


#pragma STSensorDelegate
-(void) STSensor: (STSensor *) sensor1 withData: (STSensorData *) data
{
    //Handling data from sensor
    //TODO: use sensor factory to create sensor data handler class
    // but nothing is implemented right now.
    if([sensor1 isKindOfClass: [CameraSensor class]])
    {
        //UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        //[self.view addSubview:imageView];
    }
    else if([sensor1 isKindOfClass: [QRCodeSensor class]])
    {
        //id value = [data.data objectForKey:@"result"];
    }
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{
    NSLog(@"sensor got error");
}

-(void) STSensorCancelled: (STSensor *) sensor
{
}

@end
