//
//  PhotoSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "CameraSensor.h"
#import "SCAppDelegate.h"

#import <RestKit/RKJSONParserJSONKit.h>

@interface CameraSensor ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RKRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) BOOL isTaken;
@end

@implementation CameraSensor

static CameraSensor* sensor = nil;

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor)
    {
        sensor = [super initWithSensorCallModel:model];
        
        //init camera controls
        sensor.picker = [[UIImagePickerController alloc] init];
        
        //set source type:
        if([model.command isEqualToString: @"camera"] &&
           ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] ||
            [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] ))
        {
            sensor.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            sensor.picker.mediaTypes =
                [UIImagePickerController availableMediaTypesForSourceType:
                 UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
            sensor.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        // set camera state
        self.isTaken = false;
    }
    
    return sensor;
}

-(void) start
{
    //TODO: Need to eliminate this dependency ... maybe parse in the viewController?
    //Get current view controller, so we can present camera controls
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
    
    //present image picker
    [vc presentViewController:self.picker animated:YES completion: nil];
    self.picker.delegate = self;
}

-(void) cancel
{
    //TODO: May not be able to cancel programmatically. Need to check
    [self.delegate STSensorCancelled: self];
}

#pragma UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    STSensorData * data = [[STSensorData alloc] init];
    data.data = info;
    
    [self.delegate STSensor:self withData: data];
    
    //remove image picker from screen
    [self.picker dismissViewControllerAnimated: YES completion:^(){}];
    self.picker.delegate = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // close camera
    [self.picker dismissViewControllerAnimated:YES completion:^(){}];
    //notify delegate
    [self.delegate STSensorCancelled: self];
}

#pragma mark STSensorDelegate
-(void) upload:(STSensorData *)data
{
    UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];
    //image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationDown];

    // rotate uiimage by 90 cw
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
    [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];

    // update send time
    self.time = [[NSDate date] timeIntervalSince1970];
    
    // set camera state
    self.isTaken = true;
}

#pragma mark RKRequestDelegate
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"?"];
    if([parts count] == 2) {
        parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"="];
                
        // after the file has been sent to thing broker, sent request to get content id
        if([parts count] == 2 && [[parts objectAtIndex:0] isEqualToString:@"keep-stored"] && self.isTaken) {
            [self.client get:[NSString stringWithFormat:@"/events/thing/canvas?requester=canvas"] delegate:self];
            self.isTaken = false;
        }
        
        // received content id, send append request
        if([parts count] == 2 && [[parts objectAtIndex:0] isEqualToString:@"requester"]) {
            NSDictionary *dict = [response parsedBody:nil];
            NSArray *array = nil;
            
            for (id key in dict)
            {
                array = [(NSDictionary *) key allValues];
                break;
            }
            
            // set append imagr src url
            NSString *post = [NSString stringWithFormat:@"<img src='http://kimberly.magic.ubc.ca:8080/thingbroker/events/event/content/%@?mustAttach=false' height='250' width='250'>", [[array objectAtIndex:1] objectAtIndex:0]];
            
            // post image src
            NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
            [dictRequest setObject:post forKey:@"append"];
            
            NSString *jsonRequest =  [dictRequest JSONString];
            RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
            [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];
        }
    }
}

@end
