//
//  SensorContainerTests.m
//  SensorContainerTests
//
//  Created by Jack Wu on 13-03-02.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "SensorContainerTests.h"
#import "STCSensorFactory.h"
#import "STCSensorConfig.h"

#import "CameraSensor.h"
#import "AccelerometerSensor.h"
#import "MicrophoneSensor.h"
#import "QRCodeSensor.h"

#import "STThing.h"

@implementation SensorContainerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)testInitSTThingSuccess
{
    STThing *thing = [[STThing alloc] initWithThingId:@"unit test"];
    STAssertNotNil(thing, @"nil STThing returned");

    thing = [[STThing alloc] initWithThingId:nil];
    STAssertNotNil(thing, @"nil STThing returned");
}

- (void)testSetThingIdDisplayIdForSTThingSuccess
{
    STThing *thing = [[STThing alloc] initWithThingId:nil];
 
    [STThing setThingId:@"unit test"];
    STAssertEqualObjects([STThing thingId], @"unit test", @"thing id is not 'unit test'");
    
    [STThing setDisplayId:@"1"];
    STAssertEqualObjects([STThing displayId], @"1", @"display id is not '1'");
}


- (void)testSensorConfigFromPListFileSuccess
{
    NSArray *configs = [STCSensorConfig getSensorConfig];
    
    STAssertNotNil(configs, @"no sensor configs stored plist file");
    STAssertTrue([configs isKindOfClass:[NSArray class]], @"sensor configs are not returned as NSArray");
    for(int i=0 ; i<[configs count] ; i++) {
        STAssertTrue([[configs objectAtIndex:i] isKindOfClass:[NSDictionary class]], @"sensor config objects are not NSDictionary");
        NSDictionary *dict = [configs objectAtIndex:i];
        
        switch(i) {
            case 0:
                STAssertEqualObjects([dict objectForKey:@"class"], @"MicrophoneSensor", @"element not 'MicrophoneSensor' in sensor configs");
                STAssertEqualObjects([dict objectForKey:@"name"], @"microphone", @"element not 'microphone' in sensor configs");
                break;
        
            case 1:
                STAssertEqualObjects([dict objectForKey:@"class"], @"AccelerometerSensor", @"element not 'AccelerometerSensor' in sensor configs");
                STAssertEqualObjects([dict objectForKey:@"name"], @"accelerometer", @"element not 'accelerometer' in sensor configs");
                break;

            case 2:
                STAssertEqualObjects([dict objectForKey:@"class"], @"QRCodeSensor", @"element not 'QRCodeSensor' in sensor configs");
                STAssertEqualObjects([dict objectForKey:@"name"], @"qrcode", @"element not 'qrcode' in sensor configs");
                break;
                
            case 3:
                STAssertEqualObjects([dict objectForKey:@"class"], @"CameraSensor", @"element not 'CameraSensor' in sensor configs");
                STAssertEqualObjects([dict objectForKey:@"name"], @"camera", @"element not 'camera' in sensor configs");
                break;
                
            case 4:
                STAssertEqualObjects([dict objectForKey:@"class"], @"CameraSensor", @"element not 'CameraSensor' in sensor configs");
                STAssertEqualObjects([dict objectForKey:@"name"], @"gallery", @"element not 'gallery' in sensor configs");
                break;
        }
    }
}

- (void)testGetSTSensorWithNilFailure
{
    STSensor *sensor = [STCSensorFactory getSensorWithCommand:nil];
    STAssertNil(sensor, @"STSensor created");
}

- (void)testGetSTSensorWithCommandSuccess
{
    STSensor *sensor = [STCSensorFactory getSensorWithCommand:@"camera"];
    STAssertTrue([sensor isKindOfClass:[CameraSensor class]], @"nil CameraSensor returned");

    sensor = [STCSensorFactory getSensorWithCommand:@"accelerometer"];
    STAssertTrue([sensor isKindOfClass:[AccelerometerSensor class]], @"nil AccelerometerSensor returned");

    sensor = [STCSensorFactory getSensorWithCommand:@"microphone"];
    STAssertTrue([sensor isKindOfClass:[MicrophoneSensor class]], @"nil MicrophoneSensor returned");

    sensor = [STCSensorFactory getSensorWithCommand:@"qrcode"];
    STAssertTrue([sensor isKindOfClass:[QRCodeSensor class]], @"nil QRCodeSensor returned");
}


@end
