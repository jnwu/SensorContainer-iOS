//
//  SCDataViewController.m
//  SensorContainer
//
//  Created by Daniel Yuen on 13-01-10.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//
#import "sensors/lib/config/STCSensorConfig.h"
#import "sensors/lib/factory/STCSensorFactory.h"
#import "SCAppDelegate.h"
#import "SCDataViewController.h"
#import "PhotoSensor.h"
#import "QRCodeSensor.h"

@interface SCDataViewController ()

@end

@implementation SCDataViewController
@synthesize sensor;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SCAppDelegate * appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.viewController = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}
- (IBAction)qrcodeSensorBtnTouched:(id)sender
{
    NSString * cmd = @"http://bridge.sensetecnic.com/qrcode";
    self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
    self.sensor.delegate = self;
    [self.sensor start];
}
- (IBAction)photoSensorBtnTouched:(id)sender
{
    NSString * cmd = @"http://bridge.sensetecnic.com/camera";
    self.sensor = [STCSensorFactory getSensorWithCommand: cmd];
    self.sensor.delegate = self;
    [self.sensor start];
}

#pragma STSensorDelegate

-(void) STSensor: (STSensor *) sensor1 withData: (STSensorData *) data
{
    NSLog(@"sensor got data?");
    //Handling data from sensor
    //TODO: use sensor factory to create sensor data handler class
    // but nothing is implemented right now.
    if([sensor1 isKindOfClass: [PhotoSensor class]])
    {
        UIImage *image = [data.data objectForKey:UIImagePickerControllerOriginalImage];
        [self.imageView setImage:image];
    }
    else if([sensor1 isKindOfClass: [QRCodeSensor class]])
    {
        [self.textLabel setText: [data.data objectForKey: @"result"]];
    }
}

-(void) STSensor: (STSensor *) sensor withError: (STError *) error
{
    NSLog(@"sensor got error");
}

-(void) STSensorCancelled: (STSensor *) sensor
{
    NSLog(@"sensor cancelled");
}

@end
