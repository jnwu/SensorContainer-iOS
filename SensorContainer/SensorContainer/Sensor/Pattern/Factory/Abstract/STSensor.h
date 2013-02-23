//
//  STSensor.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 12-12-18.
//  Copyright (c) 2012 Daniel Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STError.h"
#import "STCSensorCallModel.h"

#import <RestKit/RestKit.h>
#import <Restkit/JSONKit.h>
#import <Restkit/RKRequestSerialization.h>
#import <RestKit/RKMIMETypes.h>

@class STSensor;
@class STSensorData;

@protocol STSensorDelegate <NSObject>
-(void) STSensor: (STSensor *) sensor withData: (STSensorData *) data;
-(void) STSensor: (STSensor *) sensor withError: (STError *) error;
-(void) STSensorCancelled: (STSensor *) sensor;
@end

@interface STSensorData : NSObject
@property (nonatomic, strong) NSDictionary * data;
@end


@interface STSensor : NSObject <RKRequestDelegate>

/*
 Constructor.
 model: sensor call model contains all parameters for sensor to work.
 */
-(id) initWithSensorCallModel: (STCSensorCallModel *) model;

/*
 Start sensing
 */
-(void) start;

/*
 Cancel sensoring. This is required to call if the sensor is continuously sensing
 */
-(void) cancel;

/*
 Data. 
 */
-(void) data:(STSensorData *)data;


@property (weak, nonatomic) id<STSensorDelegate> delegate;
@property (strong, nonatomic) STCSensorCallModel * sensorCallModel;
@property (strong, nonatomic) RKClient *client;

@end
