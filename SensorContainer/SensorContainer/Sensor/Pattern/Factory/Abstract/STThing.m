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
@end

static STThing *thing = nil;

@implementation STThing

// the app can only interact with one thing at any time
- (id)initWithThingId:(NSString *)thingId
{
    thing = [super init];
    
    if(thing) {
        thing.thingId = thingId;
    }
    
    return thing;
}

+ (void)setThingId:(NSString *)thingId
{
    thing.thingId = thingId;
}

+ (void)setDisplayId:(NSString *)displayId
{
    thing.displayId = displayId;
}

+ (NSString *)thingId
{
    return thing.thingId;
}

+ (NSString *)displayId
{
    return thing.displayId;
}



@end
