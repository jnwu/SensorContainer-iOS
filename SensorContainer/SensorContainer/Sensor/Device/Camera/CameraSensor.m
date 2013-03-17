//
//  PhotoSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "CameraSensor.h"
#import "SCAppDelegate.h"


@interface CameraSensor ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RKRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, assign) BOOL isTaken;
@end

@implementation CameraSensor

static CameraSensor* sensor = nil;

- (id)initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(sensor && [model.command isEqualToString:@"camera"] && sensor.picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        return sensor;
    else if(sensor && [model.command isEqualToString:@"gallery"] && sensor.picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
        return sensor;
    else
        sensor = nil;
    
    if(!sensor)
    {
        
        sensor = [super initWithSensorCallModel:model];
        
        //init camera controls
        sensor.picker = [[UIImagePickerController alloc] init];
        
        //set source type:
        if([model.command isEqualToString: @"camera"])
        {
            if(([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] ||
                [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] ))
            {
                sensor.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                sensor.picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                sensor.picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            }
            else
                sensor.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if([model.command isEqualToString:@"gallery"])
            sensor.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        // set camera state
        self.isTaken = NO;
    }
    
    return sensor;
}


#pragma mark STSensor
- (void)start
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
    
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
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, 0.0);
    CGContextRotateCTM(context, 0);
    
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	image = UIGraphicsGetImageFromCurrentImageContext();
    
    // send image file to thing broker
    RKParams* params = [RKParams params];
    NSData* imageData = UIImageJPEGRepresentation(image, 0.0);
    [params setData:imageData MIMEType:@"multipart/form-data" forParam:@"photo"];
    
    // send image file
    [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
    
    // set camera state
    self.isTaken = YES;
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
            NSString *post = [NSString stringWithFormat:@"<img src='http://kimberly.magic.ubc.ca:8080/thingbroker/content/%@?mustAttach=false' height='250' width='250'>", [contentID objectAtIndex:0]];
            
            // post image src
            NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
            [dictRequest setObject:post forKey:@"append"];
            
            NSString *jsonRequest =  [dictRequest JSONString];
            RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
            [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
            
            // turn off camera state, to avoid repeatedly sends
            self.isTaken = NO;
            
            // display hud
            [MBProgressHUD showCompleteWithText:@"Uploaded Photo"];
        }        
    }
}

@end
