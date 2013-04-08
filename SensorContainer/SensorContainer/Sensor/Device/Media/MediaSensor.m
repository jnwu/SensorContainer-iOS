//
//  MediaSensor.m
//  SensorContainer
//
//  Created by Jack Wu on 13-03-12.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

#import "MediaSensor.h"
#import "SCAppDelegate.h"
#import "STThing.h"

@interface MediaSensor() <RKRequestDelegate, MPMediaPickerControllerDelegate>
@property (strong, nonatomic) MPMediaPickerController *picker;
@property (assign, nonatomic) BOOL isMediaThumbnailSent;
@property (assign, nonatomic) BOOL isMediaSent;
@end

@implementation MediaSensor

- (void)start:(NSArray *)parameters
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
    
    // start media picker
    self.picker =[[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    self.picker.delegate = self;
    self.picker.allowsPickingMultipleItems = NO;
    self.isMediaSent = NO;
    self.isMediaThumbnailSent = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
    [vc presentViewController:self.picker animated:YES completion:nil];
}

- (void)cancel
{}

- (void)uploadData:(STSensorData *)data
{
    id mediaData = [data.data objectForKey:@"mediaData"];
    id mediaThumbnailData = [data.data objectForKey:@"mediaThumbnailData"];

    if(mediaThumbnailData)
    {
        // send image file to thing broker
        RKParams* params = [RKParams params];
        NSData* imageData = UIImageJPEGRepresentation((UIImage *)mediaThumbnailData, 0.0);
        [params setData:imageData MIMEType:@"multipart/form-data" forParam:@"photo"];
        
        // send image file
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
        self.isMediaThumbnailSent = YES;
    }
    
    if(mediaData)
    {
        RKParams* params = [RKParams params];
        [params setData:(NSData *)mediaData MIMEType:@"multipart/form-data" forParam:@"audio"];
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];
        self.isMediaSent = YES;
    }
}

- (void)configure:(NSArray *)settings
{}


#pragma mark MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)theCollection
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
    [vc dismissViewControllerAnimated:YES completion:nil];

    NSArray *ArrItems=theCollection.items;
    MPMediaItem *selectedItem = [ArrItems objectAtIndex:0];
    MPMediaItemArtwork *selectedItemThumbnail = [selectedItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *mediaThumbnail = nil;
    
    // get album art
    if (selectedItemThumbnail != nil)
    {
        mediaThumbnail = [selectedItemThumbnail imageWithSize:CGSizeMake(250.0, 250.0)];
        
        if(mediaThumbnail)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:mediaThumbnail forKey:@"mediaThumbnailData"];
            STSensorData *data = [[STSensorData alloc] init];
            data.data = dict;
            
            [self.delegate STSensor:self withData: data];
        } 
    }

    // get media song 
    NSString *songTitle = [selectedItem valueForProperty:MPMediaItemPropertyTitle];
    [self.content removeAllObjects];
    [self.content addObject:songTitle];

    NSURL *assetURL = [selectedItem valueForProperty: MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: assetURL options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetPassthrough];
    NSArray *tracks = [songAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)([track.formatDescriptions objectAtIndex:0]);
    const AudioStreamBasicDescription *audioDesc = CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)desc);
    FourCharCode formatID = audioDesc->mFormatID;
    NSString *fileType = nil;
    NSString *ex = nil;
     
     
    if(formatID == kAudioFormatMPEGLayer3)
    {
        fileType = @"com.apple.quicktime-movie";
        ex = @"mov";
     
        exporter.outputFileType = fileType;
     
        NSError *error = nil;
        NSString *mp3DirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"MP3"];
        [[NSFileManager defaultManager] createDirectoryAtPath:mp3DirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
     
        NSString *exportFile = [mp3DirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", songTitle, ex]];
     
        NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
        exporter.outputURL = exportURL;
     
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:
         ^{
             NSData *mediaData = [NSData dataWithContentsOfFile:[mp3DirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", songTitle, ex]]];

             if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile])
             {
                 NSError *error = nil;
                 if ([[NSFileManager defaultManager] removeItemAtPath:exportFile error:&error] == NO)
                     NSLog(@"removeItemAtPath %@ error:%@", exportFile, error);
             }

            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:mediaData forKey:@"mediaData"];
            STSensorData *data = [[STSensorData alloc] init];
            data.data = dict;
     
            [self.delegate STSensor:self withData:data];
        }];
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.revealController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark RKRequestDelegate
- (void) request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSDictionary *jsonDict = [NSJSONSerialization   JSONObjectWithData: [[response bodyAsString] dataUsingEncoding:NSUTF8StringEncoding]
                                                               options: NSJSONReadingMutableContainers
                                                                 error: nil];
    NSArray *contentID = [jsonDict objectForKey:@"content"];
    
    // Send text to thing broker
    NSString *url = [NSString stringWithFormat:@"%@/content/%@?mustAttach=false", [STThing thingBrokerUrl], [contentID objectAtIndex:0]];
    [self.sensorDict removeAllObjects];
    [self.eventDict removeAllObjects];

    if(self.isMediaThumbnailSent)
    {
        [self.content addObject:url];
        self.isMediaThumbnailSent = NO;
    }
    
    if(self.isMediaSent)
    {
        [self.content addObject:url];
        
        [self.sensorDict setObject:self.content forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
        [self.eventDict setObject:self.sensorDict forKey:self.eventKey];

        NSString *jsonRequest =  [self.eventDict JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STThing thingId], [STThing displayId]] params:params delegate:self];

        [MBProgressHUD showCompleteWithText:@"Uploaded Media"];
        self.isMediaSent = NO;
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError: %@", error);
}

- (void)requestDidTimeout:(RKRequest *)request
{
    NSLog(@"requestDidTimeout");    
}

@end
