//
//  AccelerometerSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-01-16.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "DeviceMotionSensor.h"
#import "SCAppDelegate.h"
#import <CoreMotion/CoreMotion.h>

@interface  DeviceMotionSensor ()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMAccelerometerData *accelerometerData;
@property (weak, nonatomic) id delegate;
@end


@implementation DeviceMotionSensor

- (id)initWithSensorCallModel:(STCSensorCallModel *)model
{
    self = [super initWithSensorCallModel: model];
    
    return self;
}

- (void)start {
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startAccelerometerUpdates];
    
    self.accelerometerData = [self.motionManager accelerometerData];
    
    double x = [self.accelerometerData acceleration].x;
    
    NSLog(@"x: %f", x);
}



- (void)cancel {
    if(self.motionManager) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

@end
