//
//  ORSBoardController.h
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/1/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORSSerialPort;
@class ORSOrientation;

@interface ORSBoardController : NSObject

@property (nonatomic, readonly) ORSOrientation *orientation;
@property (nonatomic, readonly) NSInteger lightLevel;
@property (nonatomic, readonly) NSInteger sliderValue;

@property (nonatomic, strong) ORSSerialPort *port;

@end
