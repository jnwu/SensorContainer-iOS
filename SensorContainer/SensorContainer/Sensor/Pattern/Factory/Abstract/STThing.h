//
//  STThing.h
//  SensorContainer
//
//  Created by Jack Wu on 13-01-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STThing : NSObject
-(id) initWithThingId:(NSString *)thingId;

+(void) setThingId:(NSString *)thingId;
+(void) setDisplayId:(NSString *)displayId;
+(NSString *) thingId;
+(NSString *) displayId;
@end

