//
//  SCQRViewController.h
//  SensorContainer
//
//  Created by Jack Wu on 13-03-08.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//


/*
    The SCQRViewController is used to trigger the QR code scanner (zxing), where it will extract the display_id embedded in the code
    The string scanned from the code is expected to be in the format, http://base_url/mobile/display_id
 */

@interface SCQRViewController : UIViewController
@end
