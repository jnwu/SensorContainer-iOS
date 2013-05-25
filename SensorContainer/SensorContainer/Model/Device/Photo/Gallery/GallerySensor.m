//
//  GallerySensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-05-24.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "GallerySensor.h"

@implementation GallerySensor

static GallerySensor* sensor = nil;

- (id)init
{
    if(!sensor)
    {
        sensor = [super init];
        sensor.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    return sensor;
}

@end
