//
//  STCSensorFactory.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STCSensorFactory.h"

@implementation STCSensorFactory

+ (STSensor *)getSensorWithCommand:(NSString *)sensorCall
{
    if(!sensorCall && [sensorCall length] == 0)
        return nil;
    
    NSArray *sensorMapping = [self getSensorConfigWithKey: @"sensors"];
    for(NSDictionary *aSensorConfig in sensorMapping)
    {
        if([sensorCall isEqualToString:[aSensorConfig objectForKey:@"name"]])
        {
            // Create sensor device 
            NSString *className = [aSensorConfig objectForKey: @"class"];
            STSensor *sensor = [[NSClassFromString(className) alloc] init];
            
            return sensor;
        }
    }

    return nil;
}

+ (id)getSensorConfigWithKey:(NSString *)key
{
    NSString * const kConfFile = @"STSensorConfig";
    NSString *path = [[NSBundle mainBundle] pathForResource: kConfFile
                                                     ofType: @"plist"];
    
    NSDictionary *root = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return [root objectForKey: key];
}

@end
