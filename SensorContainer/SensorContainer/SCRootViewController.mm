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
#import "MBProgressHUD.h"
#import "STThing.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>

@interface SCRootViewController () <UIWebViewDelegate, STSensorDelegate, MBProgressHUDDelegate, RKRequestDelegate, RKObjectLoaderDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) STSensor *sensor;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) RKClient *client;
@end


@implementation SCRootViewController

#pragma mark SCRootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    RKURL *baseURL = [RKURL URLWithBaseURLString:@"http://kimberly.magic.ubc.ca:8080/thingbroker"];
    self.client = [RKClient clientWithBaseURL:baseURL];
    
    
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

    // set up progress for initial loading
    self.connection = [[NSURLConnection alloc] initWithRequest:requestObj delegate:self];
    [self.connection start];
    
	self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.labelText = @"Loading";
	self.hud.delegate = self;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    switch (navigationType) {
        case 0:
            if ([request.URL.scheme isEqualToString:@"inapp"]) {
                
                if ([request.URL.host isEqualToString:@"nextSlide"]) {
                    NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
                    [dictRequest setObject:@"next" forKey:@"data"];
                    
                    NSString *jsonRequest =  [dictRequest JSONString];
                    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
                    [self.client post:@"/events/event/thing/impress?keep-stored=true" params:params delegate:self];
                }
                
                if ([request.URL.host isEqualToString:@"previousSlide"]) {
                    NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
                    [dictRequest setObject:@"previous" forKey:@"data"];
                    
                    NSString *jsonRequest =  [dictRequest JSONString];
                    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
                    [self.client post:@"/events/event/thing/impress?keep-stored=true" params:params delegate:self];
                }
                
                return NO;
            }
    }
    
    
    NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"/"];
    NSRange range = {3, [parts count]-3};
    
    if([parts count] < 4) {
        return YES;
    }
    
    parts = [parts subarrayWithRange:range];
    if([(NSString *)[parts objectAtIndex:0] length] > 0) {
        self.sensor = [STCSensorFactory getSensorWithCommand:[parts objectAtIndex:0]];
        self.sensor.delegate = self;
        SEL s = NSSelectorFromString([parts objectAtIndex:1]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self.sensor respondsToSelector:s]) {
            [self.sensor performSelector:s];
#pragma clang diagnostic pop

            return NO;
        }
    }
    
    return YES;
}


#pragma mark NSURLConnectionDelegete
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.hud.mode = MBProgressHUDModeIndeterminate;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	self.hud.mode = MBProgressHUDModeIndeterminate;
	[self.hud hide:YES afterDelay:2];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.hud hide:YES];
}


#pragma mark STSensorDelegate
-(void) STSensor: (STSensor *) sensor1 withData: (STSensorData *) data
{
    //Handling data from sensor
    //TODO: use sensor factory to create sensor data handler class
    // but nothing is implemented right now.
    if([sensor1 isKindOfClass: [CameraSensor class]])
    {
        // Send text to thing broker
        NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
        [dictRequest setObject:@"http://kimberly.magic.ubc.ca:8080/thingbroker" forKey:@"video_url"];
        [dictRequest setObject:@"test!" forKey:@"foo"];
        
        NSString *jsonRequest =  [dictRequest JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        [self.client post:@"/events/event/thing/messageboard?keep-stored=true" params:params delegate:self];
        
        
        // Send image file to thing broker
        //UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];
        //RKParams* params = [RKParams params];
        //NSData* imageData = UIImagePNGRepresentation(image);
        //[params setData:imageData MIMEType:@"multipart/form-data" forParam:@"photo"];
        //NSLog(@"RKParams HTTPHeaderValueForContentType = %@", [params HTTPHeaderValueForContentType]);
        //[client post:@"/events/event/thing/messageboard?keep-stored=true" params:params delegate:self];
    }
    else if([sensor1 isKindOfClass: [QRCodeSensor class]])
    {
        //id value = [data.data objectForKey:@"result"];        
    }
    else if([sensor1 isKindOfClass: [AccelerometerSensor class]])
    {
        id x = [data.data objectForKey:@"x"];
        id y = [data.data objectForKey:@"y"];
        id z = [data.data objectForKey:@"z"];
        
        
        // Send text to thing broker
        NSMutableDictionary *acceleration = [[NSMutableDictionary alloc] init];
        [acceleration setObject: [NSString stringWithFormat:@"%@", (NSString *)x] forKey:@"x"];
        [acceleration setObject: [NSString stringWithFormat:@"%@", (NSString *)y] forKey:@"y"];
        [acceleration setObject: [NSString stringWithFormat:@"%@", (NSString *)z] forKey:@"z"];
        
        NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
        [dictRequest setObject:acceleration forKey:@"acceleration"];
        
        NSString *jsonRequest =  [dictRequest JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];
        
        
        NSString *jqueryCDN = @"http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js";
        NSData *jquery = [NSData dataWithContentsOfURL:[NSURL URLWithString:jqueryCDN]];
        NSString *jqueryString = [[NSMutableString alloc] initWithData:jquery encoding:NSUTF8StringEncoding];
        [self.webView stringByEvaluatingJavaScriptFromString:jqueryString];
        
        jqueryString = [NSString stringWithFormat:@"$('#table').append('<tr><td>%@</td><td>%@</td><td>%@</td></tr>');",
                        (NSString *)x, (NSString *)y, (NSString *)z];
        
        [self.webView stringByEvaluatingJavaScriptFromString:jqueryString];
    }
    else if([sensor1 isKindOfClass: [MicrophoneSensor class]]) {
        id audioData = [data.data objectForKey:@"audioData"];
        
        if(audioData) {
            RKParams* params = [RKParams params];
            [params setData:(NSData *)audioData MIMEType:@"multipart/form-data" forParam:@"audio"];
            [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];
       }
    }
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{
    NSLog(@"sensor got error");
}

-(void) STSensorCancelled: (STSensor *) sensor
{}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");    
}

@end
