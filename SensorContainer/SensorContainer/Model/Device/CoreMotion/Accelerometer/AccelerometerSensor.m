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
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation AccelerometerSensor

static AccelerometerSensor* sensor = nil;

-(id) init
{
    if(!sensor)
    {
        sensor = [super init];
        sensor.motionManager = [[CMMotionManager alloc] init];
    }
        
    return sensor;
}

#pragma mark STSensor
- (void)start:(NSArray *)parameters
{
    if(self.motionManager.accelerometerActive)
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
    
    // start accelerometer
    self.motionManager.accelerometerUpdateInterval = 1;
    [self.motionManager startAccelerometerUpdates];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motionManager.accelerometerUpdateInterval target:self selector:@selector(accelerometerData:) userInfo:nil repeats:YES];

    [MBProgressHUD showCompleteWithText:@"Started Accelerometer"];
}

-(void) cancel
{
    if(!self.motionManager.accelerometerActive)
        return;
    
    [self.motionManager stopAccelerometerUpdates];
    [self.timer invalidate];
    self.timer = nil;
    
    [MBProgressHUD showCompleteWithText:@"Stopped Accelerometer"];
    [self.delegate STSensorCancelled: self];
}

-(void) uploadData:(STSensorData *)data
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
    [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STSetting thingId], [STSetting displayId]] params:params delegate:self];
}

-(void) configure:(NSArray *)settings
{
    if(!self.motionManager.accelerometerActive)
        return;
    
    NSString *mode = [settings objectAtIndex:0];
    [self.timer invalidate];
    self.timer = nil;
    
    if([mode isEqualToString:@"increaseInterval"])
        self.motionManager.accelerometerUpdateInterval += 0.20;
    else if([mode isEqualToString:@"decreaseInterval"])
    {
        if(self.motionManager.accelerometerUpdateInterval - 0.20 >= 0.20)
            self.motionManager.accelerometerUpdateInterval -= 0.20;
    }

    [MBProgressHUD showText:[NSString stringWithFormat:@"Interval: %f", self.motionManager.accelerometerUpdateInterval]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motionManager.accelerometerUpdateInterval target:self selector:@selector(accelerometerData:) userInfo:nil repeats:YES];
}

#pragma mark CMMotionManager
-(void) accelerometerData:(NSTimer *) timer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    STSensorData * data = [[STSensorData alloc] init];
    
    NSString *x = [NSString stringWithFormat:@"%f", [[self.motionManager accelerometerData] acceleration].x];
    NSString *y = [NSString stringWithFormat:@"%f", [[self.motionManager accelerometerData] acceleration].y];
    NSString *z = [NSString stringWithFormat:@"%f", [[self.motionManager accelerometerData] acceleration].z];
    
    [dict setObject:x forKey: @"x"];
    [dict setObject:y forKey: @"y"];
    [dict setObject:z forKey: @"z"];
    data.data = dict;
    
    [self.delegate STSensor:self withData:data];
}

@end
