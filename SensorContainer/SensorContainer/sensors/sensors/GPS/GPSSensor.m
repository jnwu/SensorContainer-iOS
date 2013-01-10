//
//  GPSSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "GPSSensor.h"

@implementation GPSSensor

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    self = [super initWithSensorCallModel: model];
    if(self)
    {
    }
    
    return self;
}

-(void) start
{
    if([self.sensorCallModel.command isEqualToString: @"watchPosition"])
    {
    }
    else
    {
    }
}

-(void) cancel
{
    //might want to have a status flag
}

@end
