//
//  PhotoSensor.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "STSensor.h"

@protocol PhotoSensorDelegate <STSensorDelegate>

@end

@interface PhotoSensor : STSensor <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,retain) UIImagePickerController * picker;
@end
