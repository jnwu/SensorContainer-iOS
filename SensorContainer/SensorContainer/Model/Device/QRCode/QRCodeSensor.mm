//
//  QRCodeSensor.m
//  STS-Kurogo
//
//  Created by Daniel Yuen on 13-01-09.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "SCAppDelegate.h"
#import "QRCodeSensor.h"

@implementation QRCodeSensor

static QRCodeSensor* sensor = nil;

- (id)init
{
    if(!sensor)
    {
        sensor = [super init];
    }
    
    return sensor;
}


#pragma mark STSensor
- (void)start:(NSArray *)parameters
{
    SCAppDelegate * appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController * vc = appDelegate.revealController;
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc ] init];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];

    [readers addObject:qrcodeReader];
    widController.readers = readers;
    
    [vc presentViewController:widController animated:YES completion: nil];
}

- (void)cancel
{
    [self.delegate STSensorCancelled: self];    
}


#pragma mark ZXingDelegateMethods
- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:result forKey: @"result"];
    STSensorData * data = [[STSensorData alloc] init];
    data.data = dict;
    
    [self.delegate STSensor:self withData: data];
    
    //remove image picker from screen
    [controller dismissViewControllerAnimated: YES completion:^(){}];
    controller.delegate = nil;
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [controller dismissViewControllerAnimated: YES completion:^(){}];
    [self.delegate STSensorCancelled: self];
}

@end