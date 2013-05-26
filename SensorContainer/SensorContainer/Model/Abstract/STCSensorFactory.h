//
//  STCSensorFactory.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STSensor.h"

@interface STCSensorFactory : NSObject

/*
        creates the sensor object based on the parsed url from mobile web apps
 */
+ (STSensor *)getSensorWithCommand: (NSString *) sensorCall;
+ (id)getSensorConfigWithKey: (NSString *)key;
@end
