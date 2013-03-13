//
//  STThing.h
//  SensorContainer
//
//  Created by Jack Wu on 13-01-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STThing : NSObject
+ (STThing *)thing;
+ (void)setThingBrokerURL:(NSString *)url;
+ (void)setThingId:(NSString *)thingId;
+ (void)setDisplayId:(NSString *)displayId;
+ (NSString *)thingId;
+ (NSString *)displayId;
+ (NSString *)thingBrokerURL;
@end

