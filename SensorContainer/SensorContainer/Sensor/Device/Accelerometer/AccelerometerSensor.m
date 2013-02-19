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
    self.accelerometer = [self.motionManager accelerometerData];

    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSString *x = [NSString stringWithFormat:@"%f", [self.accelerometer acceleration].x];
    NSString *y = [NSString stringWithFormat:@"%f", [self.accelerometer acceleration].y];
    NSString *z = [NSString stringWithFormat:@"%f", [self.accelerometer acceleration].z];
    
    [dict setObject:x forKey: @"x"];
    [dict setObject:y forKey: @"y"];
    [dict setObject:z forKey: @"z"];
    STSensorData * data = [[STSensorData alloc] init];
    data.data = dict;
    
    [self.delegate STSensor:self withData: data];
}

@end
