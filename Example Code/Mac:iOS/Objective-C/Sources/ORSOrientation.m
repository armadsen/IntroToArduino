//
//  ORSOrientation.m
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/2/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

#import "ORSOrientation.h"

@implementation ORSOrientation

- (instancetype)initWithX:(double)x y:(double)y z:(double)z
{
	self = [self init];
	if (self) {
		_x = x;
		_y = y;
		_z = z;
	}
	return self;
}

@end
