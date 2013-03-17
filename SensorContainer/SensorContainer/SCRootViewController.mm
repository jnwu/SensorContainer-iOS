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
    RKURL *baseURL = [RKURL URLWithBaseURLString:[SCSettingViewController serverURL]];
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
    
	self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.labelText = @"Loading";
}

-(void)viewDidAppear:(BOOL)animated
{
/*
    NSString *currentURL = self.webView.request.URL.absoluteString;

    // load new page if client url has been changed
//    if(currentURL != nil && ![currentURL isEqualToString:@""] && ![currentURL isEqualToString:[SCSettingViewController clientURL]]) {
//        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:[SCSettingViewController clientURL]]];
    if(currentURL != nil && ![currentURL isEqualToString:@""] && ![currentURL isEqualToString:@"http://jnwutest.appspot.com"]) {
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://jnwutest.appspot.com"]];
        [self.webView loadRequest:requestObj];

        // set up progress for initial loading
        self.connection = [[NSURLConnection alloc] initWithRequest:requestObj delegate:self];
        [self.connection start];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.hud.labelText = @"Loading";
    }
*/ 
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // retrieve parameters from url
    NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"/"];
    NSRange range = {4, [parts count]-4};
    
    if([parts count] < 6)
        return YES;
    
    [STThing setThingId:(NSString *)[parts objectAtIndex:3]];    
    parts = [parts subarrayWithRange:range];
    if([(NSString *)[parts objectAtIndex:0] length] > 0)
    {
        // slide presentation specific controls
        if([(NSString *)[parts objectAtIndex:0] isEqualToString:@"touch"])
        {
            NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
            
            if([(NSString *)[parts objectAtIndex:1] isEqualToString:@"next"])
                [dictRequest setObject:@"next" forKey:@"data"];
            
            if([(NSString *)[parts objectAtIndex:1] isEqualToString:@"prev"])
                [dictRequest setObject:@"previous" forKey:@"data"];

            NSString *jsonRequest =  [dictRequest JSONString];
            RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
            
            [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
            
            return NO;
        }
        
        self.sensor = [STCSensorFactory getSensorWithCommand:[parts objectAtIndex:0]];
        if(!self.sensor)
            return NO;
                
        // if a sensor is running, stop it, and start new sensor
        NSString *selector = [parts objectAtIndex:1];
        if([selector isEqualToString:@"start"] && self.isSensorActive)
            [self.sensor cancel];
        
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
{
	self.hud.mode = MBProgressHUDModeIndeterminate;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.hud.mode = MBProgressHUDModeIndeterminate;
	[self.hud hide:YES afterDelay:1.5];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.hud hide:YES];
}


#pragma mark STSensorDelegate
-(void) STSensor: (STSensor *) sensor1 withData: (STSensorData *) data
{
        
    // TODO: Takeout the following if statement, temp code
    if([sensor1 isKindOfClass: [MagnetometerSensor class]])
    {
        /*

        id x = [data.data objectForKey:@"x"];
         id y = [data.data objectForKey:@"y"];
         id z = [data.data objectForKey:@"z"];
         
         NSLog(@"x: %@   y: %@   z: %@", (NSString *)x, (NSString *)y, (NSString *)z);
        

        NSString *jqueryCDN = @"http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js";
        NSData *jquery = [NSData dataWithContentsOfURL:[NSURL URLWithString:jqueryCDN]];
        NSString *jqueryString = [[NSMutableString alloc] initWithData:jquery encoding:NSUTF8StringEncoding];
        [self.webView stringByEvaluatingJavaScriptFromString:jqueryString];
        
        jqueryString = [NSString stringWithFormat:@"$('#table').append('<tr><td>%@</td><td>%@</td><td>%@</td></tr>');",
                        (NSString *)x, (NSString *)y, (NSString *)z];
        
        [self.webView stringByEvaluatingJavaScriptFromString:jqueryString];
*/ 
    }
    
    if([STThing thing])
        [sensor1 uploadData:data];
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{}

-(void) STSensorCancelled: (STSensor *) sensor
{
    self.isSensorActive = NO;
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{}

@end