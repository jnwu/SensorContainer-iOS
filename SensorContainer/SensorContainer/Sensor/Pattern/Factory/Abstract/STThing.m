//
//  STThing.m
//  SensorContainer
//
//  Created by Jack Wu on 13-01-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "STThing.h"

@interface STThing ()
@property (nonatomic, strong) NSString *thingId;
@property (nonatomic, strong) NSString *displayId;
@property (nonatomic, strong) NSString *containerUrl;
@property (nonatomic, strong) NSString *thingBrokerUrl;
@end

static STThing *thing = nil;
static NSString *kThingBrokerUrl = @"http://kimberly.magic.ubc.ca:8080/thingbroker";
static NSString *kContainerUrl = @"http://container.icd.magic.ubc.ca/api/apps";

@implementation STThing

// the app can only interact with one thing at any time
+ (STThing *)thing
{
    return thing;
}

- (id)initWithThingId:(NSString *)thingId
{
    thing = [super init];
    
    if(thing)
    {
        thing.thingId = thingId;
        [thing setContainerUrl:kContainerUrl];
        [thing setThingBrokerUrl:kThingBrokerUrl];
    }
    
    return thing;
}

+ (void)setThingId:(NSString *)thingId
{
    if(!thing)
    {
        thing = [[STThing alloc] initWithThingId:thingId];
        thing.displayId = @"";
    }
    thing.thingId = thingId;
}

+ (void)setDisplayId:(NSString *)displayId
{
    if(!thing)
        thing = [[STThing alloc] initWithThingId:@""];

    thing.displayId = displayId;
}

+ (void)setThingBrokerUrl:(NSString *)url
{
    if(!thing)
        thing = [[STThing alloc] initWithThingId:@""];

    thing.thingBrokerUrl = url;
}

+ (void)setContainerUrl:(NSString *)url
{
    if(!thing)
        thing = [[STThing alloc] initWithThingId:@""];

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
        thing = [[STThing alloc] initWithThingId:@""];
    
    return thing.thingBrokerUrl;
}

+ (NSString *)containerUrl
{
    if(!thing)
        thing = [[STThing alloc] initWithThingId:@""];
    
    return thing.containerUrl;
}

@end
