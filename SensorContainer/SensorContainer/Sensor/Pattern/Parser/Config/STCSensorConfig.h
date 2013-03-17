//
//  STCSensorConfig.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STCSensorConfig : NSObject

+ (id)getSensorConfigWithKey: (NSString *) key;
+ (NSArray *)getSensorConfig;

@end
