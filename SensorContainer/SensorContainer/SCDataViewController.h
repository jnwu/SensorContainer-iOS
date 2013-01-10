//
//  SCDataViewController.h
//  SensorContainer
//
//  Created by Daniel Yuen on 13-01-10.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSensor.h"

@interface SCDataViewController : UIViewController<STSensorDelegate>

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) STSensor * sensor;
@end
