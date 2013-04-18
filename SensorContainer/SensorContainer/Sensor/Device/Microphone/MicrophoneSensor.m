//
//  MicrophoneSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-02-19.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <FLACiOS/metadata.h>

#import "MicrophoneSensor.h"
#include "wav_to_flac.h"


@interface MicrophoneSensor ()  <AVAudioRecorderDelegate, RKRequestDelegate>
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSString *speechText;
@property (assign, nonatomic) BOOL isSpeechRecognition;
@property (assign, nonatomic) BOOL isAudioSent;
@end

static MicrophoneSensor* sensor = nil;

@implementation MicrophoneSensor

- (id)initWithSensorCallModel:(STCSensorCallModel *)model
{
    if(!sensor)
    {
        sensor = [super initWithSensorCallModel: model];
        sensor.isSpeechRecognition = NO;
        self.isAudioSent = NO;
        
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
        if(error)
        {
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            return nil;
        }
        
        error = nil;
        [sensor.audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
        if(error)
        {
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            return nil;
        }
        
        error = nil;
        [sensor.audioSession setActive:YES error:&error];
        if(error)
        {
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
            return nil;
        }
        
        
        error = nil;
        if(sensor.audioSession.inputAvailable && !sensor.recorder)
        {
            NSString *soundsDirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Sounds"];
            [[NSFileManager defaultManager] createDirectoryAtPath:soundsDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Test.wav", soundsDirectoryPath]];
            
            sensor.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:&error];
            if(error)
            {
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
- (void)start:(NSArray *)parameters
{
    if(self.audioSession.inputAvailable)
    {
        // set event and sensor keys
        self.eventKey = (NSString *)[parameters objectAtIndex:0];
        if([self.eventKey isEqualToString:@"native"])
            self.sensorKey = (NSString *)[parameters objectAtIndex:1];
        else
        {
            [MBProgressHUD showWarningWithText:@"jQuery API not supported"];
            return;
        }

        // start recording
        [self.recorder record];
        self.hud = [MBProgressHUD showLoadingWithHUD:self.hud AndText:@"Listening"];
    }
}

- (void)cancel
{
    if(self.recorder.recording == YES)
    {
        [self.hud hide:YES];
        [self.recorder stop];
        [self.delegate STSensorCancelled: self];
    }
}

-(void) configure:(NSArray *)settings
{
    NSString *setting = [settings objectAtIndex:0];
    
    if([setting isEqualToString:@"toggleSpeechRecognition"])
    {
        if(self.isSpeechRecognition)
        {
            self.isSpeechRecognition = NO;
            [MBProgressHUD showText:@"Recognition Off"];
        }
        else
        {
            self.isSpeechRecognition = YES;
            [MBProgressHUD showText:@"Recognition On"];
        }
    }
}


- (void)uploadData:(STSensorData *)data
{
    id audioData = [data.data objectForKey:@"audioData"];

/*
    id stringData = [data.data objectForKey:@"stringData"];
    
    if(stringData)
    {
        // put in sensor hash
        NSMutableDictionary *sensorDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
        
        [sensorDict setObject:stringData forKey:[NSString stringWithFormat:@"%@1", self.sensorKey]];
        [eventDict setObject:sensorDict forKey:self.eventKey];
        
        NSString *jsonRequest =  [eventDict JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
    }
*/
    if(audioData)
    {        
        RKParams* params = [RKParams params];
        [params setData:(NSData *)audioData MIMEType:@"multipart/form-data" forParam:@"audio"];
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
        self.isAudioSent = YES;
    }
}


#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	if(flag)
    {
        NSString *soundsDirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Sounds"];
        NSString *wavFile = [NSString stringWithFormat:@"%@/Test.wav", soundsDirectoryPath];
        NSData *audioData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@", wavFile]];
        
        // convert recorded audio to string
        if(self.isSpeechRecognition)
        {
            // convert file from wav to flac format
            NSString *flacFileWithoutExtension = [NSString stringWithFormat:@"%@/Test", soundsDirectoryPath];
            int interval = 30;
            char** flac_files = (char**) malloc(sizeof(char*) * 1024);
            convertWavToFlac([wavFile UTF8String], [flacFileWithoutExtension UTF8String], interval, flac_files);
            
            audioData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/Test.flac", soundsDirectoryPath]];
            if(audioData)
            {
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                                initWithURL:[NSURL URLWithString:@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US"]];
                
                [request setHTTPMethod:@"POST"];
                [request addValue:@"audio/x-flac; rate=44100" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:audioData];
                
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // extract recognition string
                int index = [result rangeOfString:@"utterance"].location;
                int length = [result rangeOfString:@"utterance"].length;
                
                if(!length)
                    return;
                
                // extract text from returned data
                self.speechText = [result substringFromIndex:index+length+3];
                index = [self.speechText rangeOfString:@"\""].location;
                self.speechText = [self.speechText substringToIndex:index];
            }
        }
        
        // send wav file to thingbroker
        if(audioData)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:audioData forKey:@"audioData"];
            
            STSensorData * data = [[STSensorData alloc] init];
            data.data = dict;
            
            [self.delegate STSensor:self withData: data];
        }

    }
}


#pragma mark RKRequestDelegate
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"?"];
    if([parts count] == 2)
    {
        parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"="];
        
        // after the file has been sent to thing broker, sent request to get content id
        if([parts count] == 2 && [[parts objectAtIndex:0] isEqualToString:@"keep-stored"] && self.isAudioSent)
        {
            NSDictionary *jsonDict = [NSJSONSerialization   JSONObjectWithData: [[response bodyAsString] dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
            NSArray *contentID = [jsonDict objectForKey:@"content"];
            
            // set append image src url
            NSString *url = [NSString stringWithFormat:@"%@/content/%@?mustAttach=false", [STThing thingBrokerUrl], [contentID objectAtIndex:0]];
            [self.content removeAllObjects];
            [self.content addObject:url];
            
            if(self.isSpeechRecognition && self.speechText)
                [self.content addObject:self.speechText];

            // put in sensor hash
            [self.sensorDict removeAllObjects];
            [self.eventDict removeAllObjects];
            [self.sensorDict setObject:self.content forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
            [self.eventDict setObject:self.sensorDict forKey:self.eventKey];

            // send image url to thingbroker
            NSString *jsonRequest =  [self.eventDict JSONString];
            RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
            [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
            
            // turn off camera state, to avoid repeatedly sends
            self.isAudioSent = NO;
            
            // display hud
            [MBProgressHUD showCompleteWithText:@"Uploaded Audio"];
        }
    }
}

@end
