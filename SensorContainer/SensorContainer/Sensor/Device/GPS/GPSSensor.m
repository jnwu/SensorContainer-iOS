//
//  GPSSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-03-14.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "GPSSensor.h"
#import "MBProgressHUD+Utility.h"

@interface GPSSensor ()  <UINavigationControllerDelegate, CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@end

@implementation GPSSensor

static GPSSensor *sensor = nil;

- (id)initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor)
    {
        sensor = [super initWithSensorCallModel: model];
        sensor.locationManager = [[CLLocationManager alloc] init];
    }
    
    return sensor;
}


#pragma mark STSensor
- (void)start:(NSArray *)parameters
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;

    [self.locationManager startUpdatingLocation];
    [MBProgressHUD showCompleteWithText:@"Started GPS"];
}

- (void)cancel
{
    [self.locationManager stopUpdatingLocation];
    [MBProgressHUD showCompleteWithText:@"Stopped GPS"];
}

- (void)uploadData:(STSensorData *)data
{
    [self.sensorDict removeAllObjects];
    [self.eventDict removeAllObjects];
    [self.sensorDict setObject:[data.data allValues] forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
    [self.eventDict setObject:self.sensorDict forKey:self.eventKey];
    
    NSString *jsonRequest =  [self.eventDict JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
}


#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    STSensorData * data = [[STSensorData alloc] init];

    [geocoder reverseGeocodeLocation:[locations objectAtIndex:0] completionHandler:^(NSArray* placemarks, NSError* error){

        if ([placemarks count] > 0)
        {
            CLPlacemark *placemark = (CLPlacemark *)[placemarks objectAtIndex:0];
            NSDictionary *dict = placemark.addressDictionary;
                                
            data.data = dict;    
            [self.delegate STSensor:self withData:data];
        }
     }];
}

@end
