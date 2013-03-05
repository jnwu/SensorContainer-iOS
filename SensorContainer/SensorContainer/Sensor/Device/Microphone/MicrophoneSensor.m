//
//  MicrophoneSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-02-19.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import "MicrophoneSensor.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import <FLACiOS/metadata.h>

#include "wav_to_flac.h"


@interface MicrophoneSensor ()  <AVAudioRecorderDelegate, RKRequestDelegate>
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
        //NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        //sensor.url = [NSString stringWithFormat:@"%@/%@.caf", NSTemporaryDirectory(), [date description]];
        
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
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Test.wav", soundsDirectoryPath]];
            
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


#pragma mark STSensor
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

-(void) upload:(STSensorData *)data
{
    id audioData = [data.data objectForKey:@"audioData"];
    id stringData = [data.data objectForKey:@"stringData"];
    
    if(audioData) {
        RKParams* params = [RKParams params];
        [params setData:(NSData *)audioData MIMEType:@"multipart/form-data" forParam:@"audio"];
        [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];
    }
    
    if(stringData) {
        // Send text to thing broker
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject: [NSString stringWithFormat:@"%@", (NSString *)stringData] forKey:@"stringData"];
        
        NSMutableDictionary *dictRequest = [[NSMutableDictionary alloc] init];
        [dictRequest setObject:dict forKey:@"data"];
        
        NSString *jsonRequest =  [dictRequest JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        [self.client post:@"/events/event/thing/canvas?keep-stored=true" params:params delegate:self];
    }
}


#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	if (flag) {
        NSString *soundsDirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Sounds"];
        NSString *wavFile = [NSString stringWithFormat:@"%@/Test.wav", soundsDirectoryPath];
        NSData *audioData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@", wavFile]];
        
        // send wav file to thingbroker
        if(audioData) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:audioData forKey:@"audioData"];
            
            STSensorData * data = [[STSensorData alloc] init];
            data.data = dict;
            
            [self.delegate STSensor:self withData: data];
        }
        
        // convert file from wav to flac format
        NSString *flacFileWithoutExtension = [NSString stringWithFormat:@"%@/Test", soundsDirectoryPath];
        int interval = 30;
        char** flac_files = (char**) malloc(sizeof(char*) * 1024);
        convertWavToFlac([wavFile UTF8String], [flacFileWithoutExtension UTF8String], interval, flac_files);
        
        audioData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/Test.flac", soundsDirectoryPath]];
        if(audioData) {
            // send flac file to google speech api
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            
            // TODO: Validate google speech api server

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US"]];
             
            [request setHTTPMethod:@"POST"];
            [request addValue:@"audio/x-flac; rate=44100" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:audioData];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    // extract recognition string
                    int index = [result rangeOfString:@"utterance"].location;
                    int length = [result rangeOfString:@"utterance"].length;
                    NSString *subStr = [result substringFromIndex:index+length+3];
                    index = [subStr rangeOfString:@"\""].location;
                    subStr = [subStr substringToIndex:index];

                    // send recognition string to thingbroker
                    [dict setObject:subStr forKey:@"stringData"];
                    STSensorData *data = [[STSensorData alloc] init];
                    data.data = dict;
                    
                    [self.delegate STSensor:self withData: data];
                }
                else if (error != nil && error.code == NSURLErrorTimedOut) {
                    // Time out error
                }
                else if (error != nil) {
                    // Error!
                }
            }];
        }
    }
}


#pragma mark RKRequestDelegate
- (void) request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{}

@end
