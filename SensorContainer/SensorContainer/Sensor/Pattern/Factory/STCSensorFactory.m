//
//  STCSensorFactory.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STCSensorFactory.h"
#import "STCSensorCallParser.h"
#import "STCSensorConfig.h"
@implementation STCSensorFactory

+(STSensor *) getSensorWithCommand: (NSString *) sensorCall
{
    STCSensorCallModel * model = [STCSensorCallParser parseSensorCallStr: sensorCall];
    NSArray * sensorMapping = [STCSensorConfig getSensorConfig];
    
    for(NSDictionary * aSensorConfig in sensorMapping)
    {
        if([model.command isEqualToString: [aSensorConfig objectForKey: @"name"]])
        {
            //create sensor
            NSString *className = [aSensorConfig objectForKey: @"class"];
            STSensor * sensor = [[NSClassFromString( className ) alloc] initWithSensorCallModel:  model];
            
            model           = nil;
            sensorMapping   = nil;
            className       = nil;
            
            return sensor;
        }
    }

    model           = nil;
    sensorMapping   = nil;
    
    NSLog(@"no sensor found.");
    return nil;
}

+(STSensor *) getHandlerWithCommand: (NSString *) sensorCall
{
    
}

@end
