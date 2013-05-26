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


/*
    callback data object from mobile resource handlers
 */

@interface STSensorData : NSObject
@property (nonatomic, strong) NSDictionary * data;
@end


/*
    base sensor object for all mobile resources
 */

@interface STSensor : NSObject <RKRequestDelegate>
@property (weak, nonatomic) id<STSensorDelegate> delegate;
@property (strong, nonatomic) RKClient *client;                 // restkit object used in posting data to thingbroker
@property (strong, nonatomic) NSMutableArray *content;          /* 
                                                                    container for storing all data from a mobile resource, so that the data all components of a post can be received at once
                                                                 
                                                                    this member is used when multiple files/data are sent per event (i.e. when sending a mp3 song, the mp3 song title, song thumbnail, and song data need to be all sent to the thingbroker, this container allows the data to be sent at once. Since files need to be uploaded first, where the content_id is replied to construct a url to referenec the uploaded data, the array conforms to the convention to all data to be sent at once)
                                                                 */
@property (strong, nonatomic) NSString *eventKey;               /*
                                                                    the eventkey is specified in the mobile web app url to set how the data will be handled once it is relayed to the web app
                                                                 
                                                                    several modes have been specified, {native, append, src, remove}, these modes are based on the supported handling in the jquery plugin
                                                                 
                                                                    while {append, src, remove} are self-explanatory, 'native' is set as user-app specific, where the relayed data is handled by a user-app defined function
                                                                 */
@property (strong, nonatomic) NSString *sensorKey;              //  specified resource in the mobile web app hyperlink
@property (strong, nonatomic) NSMutableDictionary *sensorDict;
@property (strong, nonatomic) NSMutableDictionary *eventDict;     

- (id)init;


/*
    all mobile resources are triggered by calling the 'start' method
 */
- (void)start:(NSArray *)parameters;


/*
    explicitly stops supported resources
 */
- (void)cancel;


/*
    the mobile resource data is sent to the thingbroker
 
    when a file is uploaded to the thingbroker, the thingbroker replies in a json string with a content_id, where a url can be constructed to have direct access to the file data
 */
- (void)uploadData:(STSensorData *)data;


/*
    for supported resources, specific commands have been added to manipulate the state of the resource
 */
- (void)configure:(NSArray *)settings;

@end
