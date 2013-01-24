//
//  AccelerometerSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-01-13.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "AccelerometerSensor.h"


@interface AccelerometerSensor ()  <UINavigationControllerDelegate>
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMAccelerometerData *accelerometer;
@end

@implementation AccelerometerSensor

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    self = [super initWithSensorCallModel: model];
    if(self)
    {
        self.motionManager = [[CMMotionManager alloc] init];
        self.accelerometer = [[CMAccelerometerData alloc] init];
    }
    
    return self;
}

-(void) start
{
    self.motionManager.accelerometerUpdateInterval = 1;
    [self.motionManager startAccelerometerUpdates];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(accelerometerData:) userInfo:nil repeats:YES];
}

-(void) cancel
{
    [self.motionManager stopAccelerometerUpdates];
    //TODO: May not be able to cancel programmatically. Need to check
    [self.delegate STSensorCancelled: self];
}

-(void) accelerometerData:(NSTimer *) timer {
    double x, y, z;
    
    self.accelerometer = [self.motionManager accelerometerData];
    x = [self.accelerometer acceleration].x;
    y = [self.accelerometer acceleration].y;
    z = [self.accelerometer acceleration].z;
    
    NSLog(@"x: %f   y: %f   z: %f", x, y, z);
}

@end
