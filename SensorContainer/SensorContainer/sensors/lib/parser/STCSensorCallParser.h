//
//  STCSensorCallParser.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCSensorCallModel.h"

@interface STCSensorCallParser : NSObject

/*
 Parsing sensor call, put command and param in separate fields in return object.
 callStr: sensor call
 return: an STCSensorCallModel object if it is a valid command; otherwise return nil.
 */
+(STCSensorCallModel *) parseSensorCallStr: (NSString *) callStr;

@end
