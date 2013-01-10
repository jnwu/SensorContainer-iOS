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
+(NSString *) parseCommand: (NSString *) callStr;
+(NSDictionary *) parseParam: (NSString *) callStr;
@end

@implementation STCSensorCallParser

/*
 Parsing sensor call, put command and param in separate fields in return object.
 callStr: sensor call
 return: an STCSensorCallModel object if it is a valid command; otherwise return nil.
 */
+(STCSensorCallModel *) parseSensorCallStr: (NSString *) callStr
{
    NSString * prefix = [STCSensorConfig sensorCallPrefix];
    STCSensorCallModel * result;
    NSString * command;
    
    if(![callStr hasPrefix: prefix] || [callStr isEqualToString: prefix])
    {
        return nil;
    }
    
    // command
    command = [STCSensorCallParser parseCommand: callStr];
    
    
    //param
    NSDictionary * params = [STCSensorCallParser parseParam: callStr];
    
    result = [[STCSensorCallModel alloc] initWithCommand: command param: params];
    
    prefix  = nil;
    command = nil;
    command = nil;
    params  = nil;
    
    return result;
}

#pragma private functions
+(NSString *) parseCommand: (NSString *) callStr
{
    NSString * prefix = [STCSensorConfig sensorCallPrefix];
    NSString * command = nil;
    
    //strip the prefix
    command = [callStr substringFromIndex: [prefix length]];
    
    //no command
    if([command isEqualToString: @""])
    {
        prefix = nil;
        return nil;
    }
    
    //command without param
    NSRange commandEnd = [command rangeOfString: @"?"];
    if( commandEnd.location != NSNotFound)
    {
        command = [command substringToIndex: commandEnd.location];
    }
    
    prefix = nil;
    return command;
}

+(NSDictionary *) parseParam: (NSString *) callStr
{
    NSRange commandEnd = [callStr rangeOfString: @"?"];
    
    //command with no params
    if(commandEnd.location == NSNotFound ||
       commandEnd.length == [callStr length])
    {
        return nil;
    }
    
    NSString * param = [callStr substringFromIndex: commandEnd.location + 1];
    NSArray * paramsArray = [param componentsSeparatedByString:@"&"];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    for(NSString * aParam in paramsArray)
    {
        //no key and no value
        if([aParam length] == 0)
        {
            continue;
        }

        //TODO convert escape characters?
        NSRange keyValueSeparate = [aParam rangeOfString: @"="];
        NSString * key = @"";
        NSString * value = @"";
        
        //no equal sign
        if(keyValueSeparate.location == NSNotFound)
        {
            key = aParam;
        }
        // '=' at beginning. i.e. no key
        else if(keyValueSeparate.location == 0)
        {
            continue;
        }
        // '=' at end. ie. no value
        else if(keyValueSeparate.location == [aParam length] -1)
        {
            key = [aParam substringToIndex: [aParam length] -1];
        }
        //have both key and value
        else
        {
            key = [aParam substringToIndex:keyValueSeparate.location];
            value = [aParam substringFromIndex:keyValueSeparate.location + 1];
        }
        
        [params setObject: value forKey: key];
        
        key = nil;
        value = nil;
    }
    
    param =nil;
    paramsArray = nil;
    return params;
}

@end
