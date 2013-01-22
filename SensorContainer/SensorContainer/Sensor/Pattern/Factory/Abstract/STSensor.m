//
//  STSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STSensor.h"

@implementation STSensorData
@synthesize data;
@end


@implementation STSensor
@synthesize sensorCallModel;
@synthesize delegate;

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    self = [super init];
    if(self)
    {
        self.sensorCallModel = model;
    }
    
    return self;
}

-(void) start
{
    NSLog(@"you should no get here");
}

-(void) cancel
{
    NSLog(@"you should no get here");
}


@end
