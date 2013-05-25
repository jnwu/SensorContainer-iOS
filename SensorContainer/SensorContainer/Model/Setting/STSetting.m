//
//  STThing.m
//  SensorContainer
//
//  Created by Jack Wu on 13-01-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "STSetting.h"

@interface STSetting ()
@property (nonatomic, strong) NSString *thingId;
@property (nonatomic, strong) NSString *displayId;
@property (nonatomic, strong) NSString *containerUrl;
@property (nonatomic, strong) NSString *thingBrokerUrl;
@end

static STSetting *thing = nil;
static NSString *kThingBrokerUrl = @"http://kimberly.magic.ubc.ca:8080/thingbroker";
static NSString *kContainerUrl = @"http://container.icd.magic.ubc.ca/api/apps";

@implementation STSetting

// the app can only interact with one thing at any time
+ (STSetting *)thing
{
    return thing;
}

- (id)initWithThingId:(NSString *)thingId
{
    thing = [super init];
    
    if(thing)
    {
        thing.thingId = thingId;
        thing.displayId = @"";
        [thing setContainerUrl:kContainerUrl];
        [thing setThingBrokerUrl:kThingBrokerUrl];
    }
    
    return thing;
}

+ (void)setThingId:(NSString *)thingId
{
    if(!thing)
        thing = [[STSetting alloc] initWithThingId:thingId];
    
    thing.thingId = thingId;
}

+ (void)setDisplayId:(NSString *)displayId
{
    if(!thing)
        thing = [[STSetting alloc] initWithThingId:@""];

    thing.displayId = displayId;
}

+ (void)setThingBrokerUrl:(NSString *)url
{
    if(!thing)
        thing = [[STSetting alloc] initWithThingId:@""];

    thing.thingBrokerUrl = url;
}

+ (void)setContainerUrl:(NSString *)url
{
    if(!thing)
        thing = [[STSetting alloc] initWithThingId:@""];

    thing.containerUrl = url;
}


+ (NSString *)thingId
{
    return thing.thingId;
}

+ (NSString *)displayId
{
    return thing.displayId;
}

+ (NSString *)thingBrokerUrl
{
    if(!thing)
        thing = [[STSetting alloc] initWithThingId:@""];
    
    return thing.thingBrokerUrl;
}

+ (NSString *)containerUrl
{
    if(!thing)
        thing = [[STSetting alloc] initWithThingId:@""];
    
    return thing.containerUrl;
}

@end
