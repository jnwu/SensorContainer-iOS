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
@property (nonatomic, strong) NSString *url;
@end

static STThing *thing = nil;

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
    {
        thing = [[STThing alloc] initWithThingId:@""];
    }    
    thing.displayId = displayId;
}

+ (void)setThingBrokerURL:(NSString *)url
{
    if(!thing)
    {
        thing = [[STThing alloc] initWithThingId:@""];
    }
    thing.url = url;
}

+ (NSString *)thingId
{
    return thing.thingId;
}

+ (NSString *)displayId
{
    return thing.displayId;
}

+ (NSString *)thingBrokerURL
{
    return thing.url;
}

@end
