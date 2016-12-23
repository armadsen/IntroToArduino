//
//  ORSEsploraSceneView.h
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/1/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

@import Cocoa;
@import SceneKit;

@class ORSOrientation;

@interface ORSEsploraSceneView : SCNView

@property (nonatomic, strong) ORSOrientation *orientation;
@property (nonatomic) float lightLevel;
@property (nonatomic, strong) NSColor *boardColor;

@end
