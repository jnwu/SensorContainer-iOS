//
//  PhotoSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "CameraSensor.h"
#import "SCAppDelegate.h"
#import "STSetting.h"


@interface PhotoSensor ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RKRequestDelegate>
@end

@implementation PhotoSensor


- (id)init
{
    self = [super init];
    self.picker = [[UIImagePickerController alloc] init];
    
    return self;
}


#pragma mark STSensor
- (void)start:(NSArray *)parameters
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
    
    // set event and sensor keys
    self.eventKey = (NSString *)[parameters objectAtIndex:0];
    if([self.eventKey isEqualToString:@"native"])
        self.sensorKey = (NSString *)[parameters objectAtIndex:1];
    
    //present image picker
    [vc presentViewController:self.picker animated:YES completion: nil];
    self.picker.delegate = self;
}

- (void)cancel
{
    [self.delegate STSensorCancelled: self];
}

- (void)uploadData:(STSensorData *)data
{    
    // rotate uiimage by 90 cw
    UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];

	CGSize size = [image size];
	UIGraphicsBeginImageContext(size);
	CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(cgContext, 0.0, 0.0);
    CGContextRotateCTM(cgContext, 0);
    
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	image = UIGraphicsGetImageFromCurrentImageContext();
    
    // send image file to thing broker
    NSData* imageData = UIImageJPEGRepresentation(image, 0.0);
    
    // apply image filter
    if(self.colorEffect)
    {
        CIImage *sepiaImage = [CIImage imageWithData:imageData];
        CIContext *ciContext = [CIContext contextWithOptions:nil];
        
        CIFilter *filter = [CIFilter filterWithName:self.colorEffect
                                      keysAndValues:kCIInputImageKey, sepiaImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
        sepiaImage = [filter outputImage];
        
        CGImageRef cgImage = [ciContext createCGImage:sepiaImage fromRect:[sepiaImage extent]];
        image = [UIImage imageWithCGImage:cgImage];
        imageData = UIImageJPEGRepresentation(image, 0.0);
        CGImageRelease(cgImage);
    }
    
    // send image file
    RKParams* params = [RKParams params];
    [params setData:imageData MIMEType:@"multipart/form-data" forParam:@"photo"];
    [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STSetting thingId], [STSetting displayId]] params:params delegate:self];
    
    // set camera state
    self.isTaken = YES;
}

-(void) configure:(NSArray *)settings
{
    NSString *mode = [settings objectAtIndex:0];
    
    if([mode isEqualToString:@"toggleVignette"])
    {
        if([self.colorEffect isEqualToString:@"CIVignette"])
            self.colorEffect = nil;
        else
            self.colorEffect = @"CIVignette";
    }
    else if([mode isEqualToString:@"toggleMonochrome"])
    {
        if([self.colorEffect isEqualToString:@"CIColorMonochrome"])
            self.colorEffect = nil;
        else
            self.colorEffect = @"CIColorMonochrome";
    }
    else if([mode isEqualToString:@"toggleSepia"])
    {
        if([self.colorEffect isEqualToString:@"CISepiaTone"])
            self.colorEffect = nil;
        else
            self.colorEffect = @"CISepiaTone";
    }
    else
        self.colorEffect = nil;
    
    if(self.colorEffect)
        [MBProgressHUD showText:[NSString stringWithFormat:@"%@ On", self.colorEffect]];
    else
        [MBProgressHUD showText:@"Filter Off"];
}


#pragma UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.picker dismissViewControllerAnimated:YES completion:^(){}];
    STSensorData * data = [[STSensorData alloc] init];
    data.data = info;
    
    [self.delegate STSensor:self withData: data];    
    self.picker.delegate = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // close camera
    [self.picker dismissViewControllerAnimated:YES completion:^(){}];
    //notify delegate
    [self.delegate STSensorCancelled:self];
}


#pragma mark RKRequestDelegate
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"?"];
    if([parts count] == 2)
    {
        parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"="];
                
        // after the file has been sent to thing broker, sent request to get content id
        if([parts count] == 2 && [[parts objectAtIndex:0] isEqualToString:@"keep-stored"] && self.isTaken)
        {
            NSDictionary *jsonDict = [NSJSONSerialization   JSONObjectWithData: [[response bodyAsString] dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
            NSArray *contentID = [jsonDict objectForKey:@"content"];
            
            // set append image src url
            NSString *url = [NSString stringWithFormat:@"%@/content/%@?mustAttach=false", [STSetting thingBrokerUrl], [contentID objectAtIndex:0]];
            
            // put in sensor hash
            [self.sensorDict removeAllObjects];
            [self.eventDict removeAllObjects];
            if([self.eventKey isEqualToString:@"native"])
            {
                [self.content removeAllObjects];
                [self.content addObject:url];
                [self.sensorDict setObject:self.content forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
                [self.eventDict setObject:self.sensorDict forKey:self.eventKey];
            }
            else
            {
                [self.sensorDict setObject:url forKey:@"photo"];
                [self.eventDict setObject:self.sensorDict forKey:self.eventKey];
            }
            
            // send image url to thingbroker
            NSString *jsonRequest =  [self.eventDict JSONString];
            RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
            [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STSetting thingId], [STSetting displayId]] params:params delegate:self];
            
            // turn off camera state, to avoid repeatedly sends
            self.isTaken = NO;
            
            // display hud
            [MBProgressHUD showCompleteWithText:@"Uploaded Photo"];
        }        
    }
}

@end
