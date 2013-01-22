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

@interface QRCodeSensor : STSensor <ZXingDelegate>

@end
