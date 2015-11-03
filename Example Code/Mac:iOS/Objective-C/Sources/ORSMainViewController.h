//
//  ORSMainViewController.h
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/1/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

@import Cocoa;

@class ORSSerialPortManager;
@class ORSBoardController;

@interface ORSMainViewController : NSViewController

@property (nonatomic, strong, readonly) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong, readonly) ORSBoardController *boardController;

@end

