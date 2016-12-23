//
//  ORSEsploraSceneView.m
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/1/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

#import "ORSEsploraSceneView.h"
#import "ORSOrientation.h"

@interface ORSEsploraSceneView ()

@property (nonatomic, strong) SCNNode *objectNode;
@property (nonatomic, strong) SCNGeometry *object;
@property (nonatomic, strong) SCNLight *light;

@end

@implementation ORSEsploraSceneView

- (void)commonInit
{
	_orientation = [[ORSOrientation alloc] initWithX:0 y:0 z:0];
	_boardColor = [NSColor colorWithCalibratedHue:0.546 saturation:1.0 brightness:0.476 alpha:1.0];
	_lightLevel = 1.0;
	[self setupScene];
}

- (instancetype)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)setupScene
{
	self.autoenablesDefaultLighting = YES;
	self.backgroundColor = NSColor.blueColor;
	
	SCNScene *scene = [SCNScene scene];
	
	SCNCamera *camera = [SCNCamera camera];
	camera.xFov = 10;
	camera.yFov = 45;
	
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = camera;
	cameraNode.position = SCNVector3Make(0, 0, 50);
	[scene.rootNode addChildNode:cameraNode];
	
	SCNLight *directionalLight = [SCNLight light];
	directionalLight.type = SCNLightTypeSpot;
	directionalLight.color = [NSColor whiteColor];
	directionalLight.castsShadow = YES;
//	self.light = directionalLight;
	SCNNode *directionalLightNode = [SCNNode node];
	directionalLightNode.position = SCNVector3Make(0, 20, 50);
	directionalLightNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, -0.35);
	directionalLightNode.light = directionalLight;
	[scene.rootNode addChildNode:directionalLightNode];
	
	SCNLight *ambientLight = [SCNLight light];
	ambientLight.type = SCNLightTypeAmbient;
	ambientLight.color = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];
	ambientLight.castsShadow = YES;
	self.light = ambientLight;
	SCNNode *ambientLightNode = [SCNNode node];
	ambientLightNode.light = ambientLight;
	[scene.rootNode addChildNode:ambientLightNode];
	
	self.scene = scene;
	
	[self loadBackground];
	[self loadObject];
}

- (void)loadBackground
{
	NSRect backgroundRect = NSOffsetRect(self.bounds, -NSWidth(self.bounds)/2.0, -NSHeight(self.bounds)/2.0);
	SCNShape *background = [SCNShape shapeWithPath:[NSBezierPath bezierPathWithRect:backgroundRect] extrusionDepth:0.0];
	SCNMaterial *material = [SCNMaterial material];
	material.diffuse.contents = [NSColor darkGrayColor];
	material.specular.contents = [NSColor darkGrayColor];
	material.shininess = 0.2;
	background.materials = @[material];
	
	SCNNode *backgroundNode = [SCNNode nodeWithGeometry:background];
	backgroundNode.position = SCNVector3Make(0, 0, -20);
	
	[self.scene.rootNode addChildNode:backgroundNode];
}

- (void)loadObject
{
	NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(-15, -4, 30, 8) xRadius:4 yRadius:4];
	bezierPath.flatness = 0;
	SCNShape *object = [SCNShape shapeWithPath:bezierPath extrusionDepth:0.5];
	SCNNode *objectNode = [SCNNode nodeWithGeometry:object];
	
	SCNMaterial *material = [SCNMaterial material];
	material.diffuse.contents = self.boardColor;
	material.specular.contents = [NSColor whiteColor];
	material.shininess = 0.5;
	object.materials = @[material];
	
	[self.scene.rootNode addChildNode:objectNode];
	self.objectNode = objectNode;
	self.object = object;
}

- (void)updateObjectOrientationWith:(ORSOrientation *)orientation
{
	double y = orientation.y;
	double x = orientation.x;
	double z = orientation.z;
	CGFloat roll = atan2(x, z);
	CGFloat pitch = atan2(y, sqrt(x * x + z * z)) + M_PI_2;
	
	CATransform3D transform = CATransform3DMakeRotation(roll, 0.0, 0.0, 1.0);
	transform = CATransform3DRotate(transform, pitch, 1.0, 0.0, 0.0);
	self.objectNode.transform = transform;
}

#pragma mark - Properties

- (void)setOrientation:(ORSOrientation *)orientation
{
	if (orientation != _orientation) {
		_orientation = orientation;
		[self updateObjectOrientationWith:_orientation];
	}
}

- (void)setLightLevel:(float)lightLevel
{
	if (lightLevel != _lightLevel) {
		_lightLevel = lightLevel;
		self.light.color = [NSColor colorWithCalibratedWhite:_lightLevel alpha:1.0];
	}
}

- (void)setBoardColor:(NSColor *)boardColor
{
	if (boardColor != _boardColor) {
		_boardColor = boardColor;
		
		SCNMaterial *material = [SCNMaterial material];
		material.diffuse.contents = _boardColor;
		material.shininess = 0.5;
		self.object.materials = @[material];
	}
}

@end
