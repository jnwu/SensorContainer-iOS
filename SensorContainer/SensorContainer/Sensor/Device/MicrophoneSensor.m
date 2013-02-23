//
//  MicrophoneSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-02-19.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "MicrophoneSensor.h"
#import <AVFoundation/AVFoundation.h>


@interface MicrophoneSensor ()  <AVAudioRecorderDelegate>
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) NSString *url;
@end

static MicrophoneSensor* sensor = nil;

@implementation MicrophoneSensor

-(id) initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor) {
        sensor = [super initWithSensorCallModel: model];
        
        // init destination path
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        sensor.url = [NSString stringWithFormat:@"%@/%@.caf", NSTemporaryDirectory(), [date description]];
        
        // init recorder
        NSDictionary* recorderSettings = [[NSMutableDictionary alloc] init];        
        [recorderSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recorderSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recorderSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        [recorderSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recorderSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recorderSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        NSError* error = nil;

        // init audioSession
        sensor.audioSession = [AVAudioSession sharedInstance];
        [sensor.audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&error];
        if(error){
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            return nil;
        }
        
        error = nil;
        [sensor.audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
        if(error){
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            return nil;
        }
        
        error = nil;
        [sensor.audioSession setActive:YES error:&error];
        if(error){
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            return nil;
        }
        
        
        error = nil;
        if(sensor.audioSession.inputAvailable && !sensor.recorder) {
            NSString *soundsDirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Sounds"];
            [[NSFileManager defaultManager] createDirectoryAtPath:soundsDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Test.caf", soundsDirectoryPath]];
            
            sensor.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:&error];
            if(error) {
                NSLog(@"recorder: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
                return nil;
            }
            
            [sensor.recorder setDelegate:sensor];
            [sensor.recorder prepareToRecord];
            sensor.recorder.meteringEnabled = YES;
        }
    }
    
    return sensor;
}

-(void) start
{
    if(self.audioSession.inputAvailable) {        
        [self.recorder record];
    }
}

-(void) cancel
{
    [self.recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	if (flag) {
        NSString *soundsDirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Sounds"];
        NSData *audioData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/Test.caf", soundsDirectoryPath]];
        
        if(audioData) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:audioData forKey:@"audioData"];
            
            STSensorData * data = [[STSensorData alloc] init];
            data.data = dict;
            
            [self.delegate STSensor:self withData: data];
        } else {
            NSLog(@"null audio data");
        }
        
	}
	else {
		NSLog(@"audioRecorderDidFinishRecording ERROR");
	}
}

@end
