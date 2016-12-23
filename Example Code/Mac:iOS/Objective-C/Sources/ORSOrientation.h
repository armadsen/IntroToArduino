//
//  ORSOrientation.h
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/2/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORSOrientation : NSObject

- (instancetype)initWithX:(double)x y:(double)y z:(double)z;

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double z;

@end
