//
//  STCSensorCallModel.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import "STCSensorCallModel.h"

@implementation STCSensorCallModel
@synthesize command;
@synthesize param = _param;

-(id) initWithCommand: (NSString *) inCommand param: (NSDictionary *) parameters
{
    self = [super init];
    
    if(self)
    {
        self.command = inCommand;
        _param = parameters;
    }
    
    return self;
}

@end

