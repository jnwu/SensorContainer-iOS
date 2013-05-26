//
//  STThing.h
//  SensorContainer
//
//  Created by Jack Wu on 13-01-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//


/*
        The STSetting holds the thingbroker url, web container url, thing id, and display id that are used in transferring data to the thingbroker
 */

@interface STSetting : NSObject
+ (STSetting *)thing;
+ (void)setThingBrokerUrl:(NSString *)url;
+ (void)setContainerUrl:(NSString *)url;
+ (void)setThingId:(NSString *)thingId;
+ (void)setDisplayId:(NSString *)displayId;

+ (NSString *)thingId;
+ (NSString *)displayId;
+ (NSString *)thingBrokerUrl;
+ (NSString *)containerUrl;
@end

