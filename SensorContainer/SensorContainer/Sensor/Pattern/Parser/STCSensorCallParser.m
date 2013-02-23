//
//  STCSensorCallParser.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STCSensorCallParser.h"
#import "STCSensorConfig.h"
@interface STCSensorCallParser()
@end

@implementation STCSensorCallParser

/*
 Parsing sensor call, put command and param in separate fields in return object.
 callStr: sensor call
 return: an STCSensorCallModel object if it is a valid command; otherwise return nil.
 */
+(STCSensorCallModel *) parseSensorCallStr: (NSString *) callStr
{
    if(!callStr || [callStr length] == 0) {
        return nil;
    }
    
    return [[STCSensorCallModel alloc] initWithCommand: callStr param: nil];
}

@end
