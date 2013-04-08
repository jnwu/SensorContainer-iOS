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

- (id)initWithSensorCallModel:(STCSensorCallModel *)model
{
    self = [super init];
        
    if(self)
    {
        RKURL *baseURL = [RKURL URLWithBaseURLString:[SCSettingViewController serverURL]];
        self.client = [RKClient clientWithBaseURL:baseURL];
        self.sensorCallModel = model;
        self.content = [[NSMutableArray alloc] init];
        self.sensorDict = [[NSMutableDictionary alloc] init];
        self.eventDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)start:(NSArray *)parameters
{
    NSLog(@"you should not get here");
}

- (void)cancel
{
    NSLog(@"you should not get here");
}

- (void)uploadData:(STSensorData *)data
{
    NSLog(@"you should not get here");
}

- (void)configure:(NSArray *)settings
{
    NSLog(@"you should not get here");    
}

- (void)sendFileUrl:(NSString *)url
{
    
}

@end
