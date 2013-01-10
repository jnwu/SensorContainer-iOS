//
//  PhotoSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "PhotoSensor.h"
#import "SCAppDelegate.h"
@implementation PhotoSensor
@synthesize picker;

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    self = [super initWithSensorCallModel: model];
    if(self)
    {
        //init camera controls
        self.picker = [[UIImagePickerController alloc] init];
//        self.picker.delegate = self;
        
        //set source type:
        if([model.command isEqualToString: @"camera"] &&
           ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] ||
            [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] ))
        {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            self.picker.mediaTypes =
                [UIImagePickerController availableMediaTypesForSourceType:
                 UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        
        NSLog(@"photo sensor!");
    }
    
    return self;
}

-(void) start
{
    //TODO: Need to eliminate this dependency ... maybe parse in the viewController?
    //Get current view controller, so we can present camera controls
    SCAppDelegate * appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController * vc = appDelegate.viewController;
    
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

#pragma UINavigationViewController
-(void)navigationController:(UINavigationController *)navigationController
      didShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
}

@end
