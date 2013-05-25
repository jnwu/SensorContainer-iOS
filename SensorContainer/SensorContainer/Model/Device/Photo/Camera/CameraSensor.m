//
//  CameraSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-05-24.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "CameraSensor.h"

@implementation CameraSensor

static CameraSensor* sensor = nil;

- (id)init
{
    if(!sensor)
    {
        sensor = [super init];
        
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
    
    return sensor;
}

@end
