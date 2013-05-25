//
//  STSensor.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCSettingViewController.h"
#import "MBProgressHUD+Utility.h"
#import "STSetting.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>

@class STSensor;
@class STSensorData;

@protocol STSensorDelegate <NSObject>
- (void)STSensor: (STSensor *) sensor withData: (STSensorData *) data;
- (void)STSensor: (STSensor *) sensor withError: (NSError *) error;
- (void)STSensorCancelled: (STSensor *) sensor;
@end

@interface STSensorData : NSObject
@property (nonatomic, strong) NSDictionary * data;
@end


@interface STSensor : NSObject <RKRequestDelegate>
@property (weak, nonatomic) id<STSensorDelegate> delegate;
@property (strong, nonatomic) RKClient *client;
@property (strong, nonatomic) NSMutableArray *content;
@property (strong, nonatomic) NSString *eventKey;
@property (strong, nonatomic) NSString *sensorKey;
@property (strong, nonatomic) NSMutableDictionary *sensorDict;
@property (strong, nonatomic) NSMutableDictionary *eventDict;

- (id)init;
- (void)start:(NSArray *)parameters;
- (void)cancel;
- (void)uploadData:(STSensorData *)data;
- (void)configure:(NSArray *)settings;

@end
