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
-(void) data:(STSensorData *)data
{
    NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
    [dictRequest setObject:@"http://kimberly.magic.ubc.ca:8080/thingbroker" forKey:@"video_url"];
    [dictRequest setObject:@"test!" forKey:@"foo"];
    
    NSString *jsonRequest =  [dictRequest JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [self.client post:@"/events/event/thing/messageboard?keep-stored=true" params:params delegate:self];
    
/*
    // Send image file to thing broker
    UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];
    RKParams* params = [RKParams params];
    NSData* imageData = UIImagePNGRepresentation(image);
    [params setData:imageData MIMEType:@"multipart/form-data" forParam:@"photo"];
    NSLog(@"RKParams HTTPHeaderValueForContentType = %@", [params HTTPHeaderValueForContentType]);
    [self.client post:@"/events/event/thing/messageboard?keep-stored=true" params:params delegate:self];
*/
}


@end
