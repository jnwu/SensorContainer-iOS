//
//  STCSensorCallModel.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STCSensorCallModel : NSObject
{
    NSDictionary * _param;
}

- (id)initWithCommand: (NSString *) inCommand param: (NSDictionary *) parameters;

@property(nonatomic, retain) NSString * command;
@property(nonatomic, readonly) NSDictionary * param;


@end