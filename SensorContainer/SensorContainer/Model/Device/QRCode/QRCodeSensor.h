//
//  QRCodeSensor.h
//  STS-Kurogo
//
//  Created by Daniel Yuen on 13-01-09.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import "STSensor.h"

/*
    The mobile resource QRCodeScanner is a modified camera resource, where it is used to scan for the display_id for apps in the web container
 */

@interface QRCodeSensor : STSensor <ZXingDelegate>
@end
