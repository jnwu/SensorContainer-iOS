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
#import "STSetting.h"

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
        // send image file to thing brokerr
        RKParams* params = [RKParams params];
        NSData* imageData = UIImageJPEGRepresentation((UIImage *)mediaThumbnailData, 0.0);
        [params setData:imageData MIMEType:@"multipart/form-data" forParam:@"photo"];
        
        // send image file
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STSetting thingId], [STSetting displayId]] params:params delegate:self];
        self.isMediaThumbnailSent = YES;
    }
    
    if(mediaData)
    {
        RKParams* params = [RKParams params];
        [params setData:(NSData *)mediaData MIMEType:@"multipart/form-data" forParam:@"audio"];
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STSetting thingId], [STSetting displayId]] params:params delegate:self];
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

    /*
        a NSMutableAsset object is created based on the metadata from the nsmediaitem, where the AVAssetExportSession object copies the data to a specified location, allowing the data to be sent
     */
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
     
    // at this time, only mp3 song files are enabled to be sent
    if(formatID == kAudioFormatMPEGLayer3)
    {
        fileType = @"com.apple.quicktime-movie";
        ex = @"mov";
     
        exporter.outputFileType = fileType;
        
        // exports the mp3 file
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

             // file cleanup after exporting
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
    
    // get content id from the thingbroker response
    NSString *url = [NSString stringWithFormat:@"%@/content/%@?mustAttach=false", [STSetting thingBrokerUrl], [contentID objectAtIndex:0]];
    [self.sensorDict removeAllObjects];
    [self.eventDict removeAllObjects];

    // reset isMediaThumbnailSent after a response has been received
    if(self.isMediaThumbnailSent)
    {
        [self.content addObject:url];
        self.isMediaThumbnailSent = NO;
    }
    
    /*
        the thingbroker replies with a content_id when a file is sent to the server, where a url can be constructed to have direct access to the uploaded file
     
        a second post is sent to the thingbroker with the constructed url that points to this file data
     */
    if(self.isMediaSent)
    {
        [self.content addObject:url];
        
        [self.sensorDict setObject:self.content forKey:[NSString stringWithFormat:@"%@", self.sensorKey]];
        [self.eventDict setObject:self.sensorDict forKey:self.eventKey];

        NSString *jsonRequest =  [self.eventDict JSONString];
        RKParams *params = [RKRequestSerialization serializationWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
        
        [self.client post:[NSString stringWithFormat:@"/things/%@%@/events?keep-stored=true", [STSetting thingId], [STSetting displayId]] params:params delegate:self];

        [MBProgressHUD showCompleteWithText:@"Uploaded Media"];
        self.isMediaSent = NO;
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    // aborts the transfer on error
    self.isMediaSent = NO;
    self.isMediaThumbnailSent = NO;
}

- (void)requestDidTimeout:(RKRequest *)request
{
    // aborts the transfer on timeout
    self.isMediaSent = NO;
    self.isMediaThumbnailSent = NO;
}

@end
