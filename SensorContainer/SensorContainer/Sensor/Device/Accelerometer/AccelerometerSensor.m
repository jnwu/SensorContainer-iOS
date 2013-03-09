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

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor) {
        sensor = [super initWithSensorCallModel: model];
        sensor.motionManager = [[CMMotionManager alloc] init];
    }
        
    return sensor;
}

#pragma mark STSensor
-(void) start
{
    if(self.motionManager.accelerometerActive) {
        return;
    }
    
    self.motionManager.accelerometerUpdateInterval = 1;
    [self.motionManager startAccelerometerUpdates];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motionManager.accelerometerUpdateInterval target:self selector:@selector(accelerometerData:) userInfo:nil repeats:YES];
}

-(void) cancel
{
    [self.motionManager stopAccelerometerUpdates];
    [self.timer invalidate];
    self.timer = nil;
    
    [self.delegate STSensorCancelled: self];    
}

-(void) uploadData:(STSensorData *)data ForThing:(NSString *)thing
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
    [dictRequest setObject:acceleration forKey:@"data"];
    
    NSString *jsonRequest =  [dictRequest JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [self.client post:[NSString stringWithFormat:@"/things/%@/events?keep-stored=true", thing] params:params delegate:self];
}

-(void) configure:(NSArray *)settings
{
    if(!self.motionManager.accelerometerActive) {
        return;
    }
    
    NSString *mode = [settings objectAtIndex:0];
    [self.timer invalidate];
    self.timer = nil;
    
    if([mode isEqualToString:@"increaseInterval"]) {
        self.motionManager.accelerometerUpdateInterval += 0.20;
    } else if([mode isEqualToString:@"decreaseInterval"]) {
        if(self.motionManager.accelerometerUpdateInterval - 0.20 <= 0) {
            return;
        }

        self.motionManager.accelerometerUpdateInterval -= 0.20;
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motionManager.accelerometerUpdateInterval target:self selector:@selector(accelerometerData:) userInfo:nil repeats:YES];
}

#pragma mark CMMotionManager
-(void) accelerometerData:(NSTimer *) timer {    
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
