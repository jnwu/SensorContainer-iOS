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
#import "MicrophoneSensor.h"
#import "SCSettingViewController.h"
#import "MagnetometerSensor.h"
#import "GPSSensor.h"
#import "MediaSensor.h"
#import "TouchSensor.h"
#import "MBProgressHUD.h"
#import "STThing.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>


@interface SCRootViewController () <UIWebViewDelegate, STSensorDelegate, RKRequestDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) STSensor *sensor;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) RKClient *client;
@property (assign, nonatomic) BOOL isSensorActive;
@property (strong, nonatomic) NSString *thing;
@property (strong, nonatomic) NSString *url;
@end


@implementation SCRootViewController

- (id)initWithURL:(NSString *)url
{
    self = [super init];
   
    if(self)
        self.url = [[NSString alloc] initWithString:url];
    
    return self;
}

- (void)dealloc
{
    self.webView.delegate = nil;
}

#pragma mark UIViewController
- (void)viewWillLayoutSubviews
{
    self.webView.frame = self.view.frame;
}


#pragma mark SCRootViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view.backgroundColor = [UIColor whiteColor];
    self.isSensorActive = NO;
    
    // init restkit client
    RKURL *baseURL = [RKURL URLWithBaseURLString:[STThing thingBrokerUrl]];
    self.client = [RKClient clientWithBaseURL:baseURL];
    
    // add webview
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scalesPageToFit = YES;

	// load mobile web app
    [self.webView loadRequest:requestObj];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];

    // set up progress for initial loading
    self.connection = [[NSURLConnection alloc] initWithRequest:requestObj delegate:self];
    [self.connection start];
    
    self.hud = [MBProgressHUD showLoadingWithHUD:self.hud AndText:@"Loading"];
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // retrieve parameters from url
    NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"/"];
    
    if([parts count] <= 4)
        return YES;
    else
    {
        if([parts count] <= 6 && [parts objectAtIndex:5] && ![(NSString *)[parts objectAtIndex:5] isEqualToString:@"cancel"])
            return YES;        
    }


    [STThing setThingId:(NSString *)[parts objectAtIndex:3]];
    NSRange range = {4, [parts count]-4};
    parts = [parts subarrayWithRange:range];
    if([(NSString *)[parts objectAtIndex:0] length] > 0)
    {
        self.sensor = [STCSensorFactory getSensorWithCommand:[parts objectAtIndex:0]];
        if(!self.sensor)
            return NO;
        
        // if a sensor is running, stop it, and start new sensor
        NSString *selector = [parts objectAtIndex:1];
        if([selector isEqualToString:@"start"])
        {
            if([(NSString *) [parts objectAtIndex:2] isEqualToString:@"native"] && [parts count] < 4)
            {
                [MBProgressHUD showWarningWithText:@"Invalid URL Specified"];
                return NO;
            }
            
            if(self.isSensorActive)
                [self.sensor cancel];
        }
        
        // check for function parameters
        if([parts count] > 2)
        {
            NSRange range = {2, [parts count]-2};
            selector = [NSString stringWithFormat:@"%@:", selector];
            parts = [parts subarrayWithRange:range];
        }
        else
            parts = nil;
        
        self.isSensorActive = YES;
        self.sensor.delegate = self;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

        if ([self.sensor respondsToSelector:NSSelectorFromString(selector)])
            [self.sensor performSelector:NSSelectorFromString(selector) withObject:parts afterDelay:0];

#pragma clang diagnostic pop

        return NO;
    }
    
    return YES;
}


#pragma mark NSURLConnectionDelegete
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.hud hide:YES afterDelay:2];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.hud hide:YES];
}


#pragma mark STSensorDelegate
- (void)STSensor:(STSensor *)sensor withData:(STSensorData *)data
{
    // TODO: Takeout the following if statement, temp code
    if([sensor isKindOfClass: [AccelerometerSensor class]])
    {
/*
        id x = [data.data objectForKey:@"x"];
        id y = [data.data objectForKey:@"y"];
        id z = [data.data objectForKey:@"z"];
         
        NSLog(@"x: %@   y: %@   z: %@", (NSString *)x, (NSString *)y, (NSString *)z);
*/ 
    }
    
    if([STThing thing])
        [sensor uploadData:data];
}

- (void)STSensor:(STSensor *)sensor withError:(STError *)error
{}

-(void) STSensorCancelled: (STSensor *) sensor
{
    self.isSensorActive = NO;
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{}

@end