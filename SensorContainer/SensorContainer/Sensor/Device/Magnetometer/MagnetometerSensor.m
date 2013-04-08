//
//  MagnetometerSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-03-14.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "MagnetometerSensor.h"

@interface MagnetometerSensor ()  <UINavigationControllerDelegate>
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation MagnetometerSensor

static MagnetometerSensor* sensor = nil;

- (id)initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor)
    {
        sensor = [super initWithSensorCallModel: model];
        sensor.motionManager = [[CMMotionManager alloc] init];
    }
    
    return sensor;
}

#pragma mark STSensor
- (void)start:(NSArray *)parameters
{
    if(self.motionManager.magnetometerActive)
        return;
    
    // set event and sensor keys
    self.eventKey = (NSString *)[parameters objectAtIndex:0];
    if([self.eventKey isEqualToString:@"native"])
        self.sensorKey = (NSString *)[parameters objectAtIndex:1];
    else
    {
        [MBProgressHUD showWarningWithText:@"jQuery API not supported"];
        return;
    }
    
    // start magnetometer
    self.motionManager.magnetometerUpdateInterval = 1;
    [self.motionManager startMagnetometerUpdates];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motionManager.magnetometerUpdateInterval target:self selector:@selector(magnetometerData:) userInfo:nil repeats:YES];
    
    [MBProgressHUD showCompleteWithText:@"Started Magnetometer"];
}

- (void)cancel
{
    if(!self.motionManager.magnetometerActive)
        return;
    
    [self.motionManager stopMagnetometerUpdates];
    [self.timer invalidate];
    self.timer = nil;
    
    [MBProgressHUD showCompleteWithText:@"Stopped Magnetometer"];
    [self.delegate STSensorCancelled: self];
}

- (void)uploadData:(STSensorData *)data
{
    id x = [data.data objectForKey:@"x"];
    id y = [data.data objectForKey:@"y"];
    id z = [data.data objectForKey:@"z"];
    
    // Send text to thing broker
    [self.content removeAllObjects];
    [self.content addObject:(NSString *)x];
    [self.content addObject:(NSString *)y];
    [self.content addObject:(NSString *)z];
    
    // put in sensor hash
    [self.sensorDict removeAllObjects];
    [self.eventDict removeAllObjects];
    [self.sensorDict setObject:self.content forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
    [self.eventDict setObject:self.sensorDict forKey:self.eventKey];
    
    NSString *jsonRequest =  [self.eventDict JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
}

- (void)configure:(NSArray *)settings
{
    if(!self.motionManager.magnetometerActive)
        return;
    
    NSString *mode = [settings objectAtIndex:0];
    [self.timer invalidate];
    self.timer = nil;
    
    if([mode isEqualToString:@"increaseInterval"])
        self.motionManager.magnetometerUpdateInterval += 0.20;
    else if([mode isEqualToString:@"decreaseInterval"])
    {
        if(self.motionManager.magnetometerUpdateInterval - 0.20 >= 0.20)
            self.motionManager.magnetometerUpdateInterval -= 0.20;
    }
    
    [MBProgressHUD showText:[NSString stringWithFormat:@"Interval: %f", self.motionManager.magnetometerUpdateInterval]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motionManager.magnetometerUpdateInterval target:self selector:@selector(magnetometerData:) userInfo:nil repeats:YES];
}

#pragma mark CMMotionManager
- (void)magnetometerData:(NSTimer *)timer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    STSensorData * data = [[STSensorData alloc] init];
    
    CMMagneticField field = [[self.motionManager magnetometerData] magneticField];
    
    NSString *x = [NSString stringWithFormat:@"%f", field.x];
    NSString *y = [NSString stringWithFormat:@"%f", field.y];
    NSString *z = [NSString stringWithFormat:@"%f", field.z];
    
    [dict setObject:x forKey: @"x"];
    [dict setObject:y forKey: @"y"];
    [dict setObject:z forKey: @"z"];
    
    data.data = dict;    
    [self.delegate STSensor:self withData:data];
}

@end
