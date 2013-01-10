//
//  STCSensorConfig.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STCSensorConfig.h"

@implementation STCSensorConfig

/*
 Load sensor config defined in plist.
 key: specify this key to get value defined in config
 return: value of the config
 */
+(id) getSensorConfigWithKey: (NSString *) key
{
    NSString * const kConfFile = @"STSensorConfig";
    NSString *path = [[NSBundle mainBundle] pathForResource: kConfFile
                                                     ofType: @"plist"];
    
    NSDictionary *root = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    path = nil;
    
    return [root objectForKey: key];
}

/*
 Get the sensor call prefix
 return: sensor call prefix
 */
+(NSString *) sensorCallPrefix
{
    return [STCSensorConfig getSensorConfigWithKey: @"sensorCallPrefix"];
}

+(NSArray *) getSensorConfig
{
    return [STCSensorConfig getSensorConfigWithKey: @"sensors"];
}

@end
