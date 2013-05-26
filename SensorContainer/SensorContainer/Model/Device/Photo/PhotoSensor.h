//
//  PhotoSensor.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STSensor.h"

/*
        The mobile resource for photo, which includes both the camera and gallery resources
 */

@interface PhotoSensor : STSensor
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) NSString *colorEffect;
@property (nonatomic, assign) BOOL isTaken;
@end
