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
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int count;
@end

@implementation AccelerometerSensor

static AccelerometerSensor* sensor = nil;

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor) {
        sensor = [super initWithSensorCallModel: model];

        sensor.motionManager = [[CMMotionManager alloc] init];
        sensor.accelerometer = [[CMAccelerometerData alloc] init];
        sensor.count = 0;
    }
        
    return sensor;
}

-(void) start
{
    self.motionManager.accelerometerUpdateInterval = 1;
    [self.motionManager startAccelerometerUpdates];
        
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(accelerometerData:) userInfo:nil repeats:YES];
}

-(void) cancel
{
    //TODO: May not be able to cancel programmatically. Need to check
    [self.motionManager stopAccelerometerUpdates];
    [self.timer invalidate];
    self.timer = nil;
}

-(void) accelerometerData:(NSTimer *) timer {
    if(self.count == 4) {
        [self.motionManager stopAccelerometerUpdates];
        [self.timer invalidate];
        self.timer = nil;
        self.count = 0;
        return;
    }

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
    
    self.count++;
}

-(void) data:(STSensorData *)data
{
    id x = [data.data objectForKey:@"x"];
    id y = [data.data objectForKey:@"y"];
    id z = [data.data objectForKey:@"z"];
    
    // Send text to thing broker
    NSMutableDictionary *acceleration = [[NSMutableDictionary alloc] init];
    [acceleration setObject: [NSString stringWithFormat:@"%@", (NSString *)x] forKey:@"x"];
    [acceleration setObject: [NSString stringWithFormat:@"%@", (NSString *)y] forKey:@"y"];
    [acceleration setObject: [NSString stringWithFormat:@"%@", (NSString *)z] forKey:@"z"];
    
    NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
    [dictRequest setObject:acceleration forKey:@"acceleration"];
    
    NSString *jsonRequest =  [dictRequest JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];
}

#pragma mark RKRequestDelegate
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSLog(@"accelerometer didLoadResponse");
    //    NSString *intervalString = [NSString stringWithFormat:@"%i", (int)time];
    
    
}


@end
