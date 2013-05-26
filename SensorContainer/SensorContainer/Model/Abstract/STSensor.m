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
@synthesize delegate;


- (id)init
{
    self = [super init];
    
    if(self)
    {
        RKURL *baseURL = [RKURL URLWithBaseURLString:[SCSettingViewController serverURL]];
        self.client = [RKClient clientWithBaseURL:baseURL];
        self.content = [[NSMutableArray alloc] init];
        self.sensorDict = [[NSMutableDictionary alloc] init];
        self.eventDict = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)start:(NSArray *)parameters
{}

- (void)cancel
{}

- (void)uploadData:(STSensorData *)data
{}

- (void)configure:(NSArray *)settings
{}

@end
