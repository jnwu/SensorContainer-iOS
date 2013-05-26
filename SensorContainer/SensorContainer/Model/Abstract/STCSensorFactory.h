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

/*
        returns the list of resources defined in the app, the supported resources are stored in the plist file
 */
+ (id)getSensorConfigWithKey: (NSString *)key;
@end
