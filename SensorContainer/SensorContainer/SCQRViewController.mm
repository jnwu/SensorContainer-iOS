//
//  SCQRViewController.m
//  SensorContainer
//
//  Created by Jack Wu on 13-03-08.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "SCQRViewController.h"
#import "QRCodeSensor.h"
#import "STThing.h"
#import "STSensor.h"
#import "STCSensorFactory.h"
#import "GHMenuViewController.h"
#import "MBProgressHUD+Utility.h"

@interface SCQRViewController () <STSensorDelegate>
@property (nonatomic, strong) STSensor *sensor;
@end

@implementation SCQRViewController

- (void)viewDidAppear:(BOOL)animated {
    self.sensor = [STCSensorFactory getSensorWithCommand:@"qrcode"];
    self.sensor.delegate = self;
    [self.sensor start];
}

#pragma mark STSensorDelegate
-(void) STSensor: (STSensor *) sensor1 withData: (STSensorData *) data {
    [GHMenuViewController setPreviousAsContentViewController];
    NSArray *parts = [[data.data objectForKey:@"result"] componentsSeparatedByString:@"/"];

    if([parts count] == 5) {
        [STThing setDisplayId:[parts objectAtIndex:4]];
        [MBProgressHUD showCompleteWithText:@"Updated Display ID"];
    }
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{}

-(void) STSensorCancelled: (STSensor *) sensor {
    [GHMenuViewController setPreviousAsContentViewController];        
}

@end
