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
#import "MBProgressHUD.h"
#import "STThing.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>

@interface SCRootViewController () <UIWebViewDelegate, CameraSensorDelegate, MBProgressHUDDelegate, RKRequestDelegate, RKObjectLoaderDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) STSensor *sensor;
@property (strong, nonatomic) MBProgressHUD *hud;
@end


@implementation SCRootViewController

#pragma mark SCRootViewController
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
        RKURL *baseURL = [RKURL URLWithBaseURLString:@"http://kimberly.magic.ubc.ca:8080/thingbroker"];
        RKClient* client = [RKClient clientWithBaseURL:baseURL];
        
        
        // Send text to thing broker
        NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
        [dictRequest setObject:@"http://kimberly.magic.ubc.ca:8080/thingbroker" forKey:@"video_url"];
        [dictRequest setObject:@"test!" forKey:@"foo"];
        
        NSString *jsonRequest =  [dictRequest JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        [client post:@"/events/event/thing/messageboard?keep-stored=true" params:params delegate:self];
        
        
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
                
        NSString *jqueryCDN = @"http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js";
        NSData *jquery = [NSData dataWithContentsOfURL:[NSURL URLWithString:jqueryCDN]];
        NSString *jqueryString = [[NSMutableString alloc] initWithData:jquery encoding:NSUTF8StringEncoding];
        [self.webView stringByEvaluatingJavaScriptFromString:jqueryString];
        
        jqueryString = [NSString stringWithFormat:@"$('#table').append('<tr><td>%@</td><td>%@</td><td>%@</td></tr>');",
                        (NSString *)x, (NSString *)y, (NSString *)z];
        
        [self.webView stringByEvaluatingJavaScriptFromString:jqueryString];
    }
}


-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{
    NSLog(@"sensor got error");
}

-(void) STSensorCancelled: (STSensor *) sensor
{
}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    if ([response isSuccessful]) {
        // Looks like we have a 201 response of type 'application/json'
        NSLog(@"didLoadResponse %@", [response bodyAsString]);
    } else if ([response isError]) {
        // Response status was either 400..499 or 500..599
        NSLog(@"Ouch! We have an HTTP error. Status Code description: %@", [response localizedStatusCodeString]);
    }
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");    
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    NSLog(@"didLoadObject");
}

- (void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader {
    NSLog(@"objectLoaderDidFinishLoading");    
}

@end
