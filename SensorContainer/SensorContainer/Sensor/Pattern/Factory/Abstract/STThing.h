//
//  STThing.h
//  SensorContainer
//
//  Created by Jack Wu on 13-01-27.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STThing : NSObject
@property (strong, nonatomic) NSString *thingId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSDictionary *metadata;
@property (strong, nonatomic) NSMutableArray *followers;
@property (strong, nonatomic) NSMutableArray *following;
@property (assign, nonatomic) BOOL state;
@end

