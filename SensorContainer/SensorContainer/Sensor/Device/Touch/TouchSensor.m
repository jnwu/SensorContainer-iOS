//
//  TouchSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-03-22.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "TouchSensor.h"

@implementation TouchSensor

static TouchSensor *sensor = nil;

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor)
        sensor = [super initWithSensorCallModel: model];
    
    return sensor;
}

- (void)start:(NSArray *)parameters
{
    NSLog(@"p: %@", [parameters objectAtIndex:0]);
    
    if(([(NSString *)[parameters objectAtIndex:0] isEqualToString:@"native"] && [parameters count] < 3) || [parameters count] < 2)
    {
        [MBProgressHUD showWarningWithText:@"Touch Text Missing"];
        return;
    }
    
    // set event and sensor keys
    NSString *text = nil;
    self.eventKey = (NSString *)[parameters objectAtIndex:0];
    if([self.eventKey isEqualToString:@"native"])
    {
        self.sensorKey = (NSString *)[parameters objectAtIndex:1];
        text = (NSString *)[parameters objectAtIndex:2];
    }
    else
        text = (NSString *)[parameters objectAtIndex:1];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    STSensorData *data = [[STSensorData alloc] init];
    
    [dict setObject:text forKey: @"text"];
    data.data = dict;
    
    [self.delegate STSensor:self withData:data];
}

- (void)cancel
{}

- (void)uploadData:(STSensorData *)data
{
    id text = [data.data objectForKey:@"text"];
    
    NSMutableDictionary *sensorDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
    
    // put in sensor hash
    if([self.eventKey isEqualToString:@"native"])
    {
        [self.content removeAllObjects];
        [self.content addObject:(NSString *)text];
        [sensorDict setObject:self.content forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
        [eventDict setObject:sensorDict forKey:self.eventKey];
    }
    else
    {
        [sensorDict setObject:text forKey:@"text"];
        [eventDict setObject:sensorDict forKey:self.eventKey];
    }

    NSString *jsonRequest =  [eventDict JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
}

@end
