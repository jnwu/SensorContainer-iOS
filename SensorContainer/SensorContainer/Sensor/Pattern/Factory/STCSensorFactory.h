//
//  STCSensorFactory.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSensor.h"

@interface STCSensorFactory : NSObject
+ (STSensor *)getSensorWithCommand: (NSString *) sensorCall;
@end
