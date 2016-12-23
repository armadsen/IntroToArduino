//
//  ORSMainViewController.m
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/1/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

#import "ORSMainViewController.h"
@import ORSSerial;
#import "ORSBoardController.h"
#import "ORSEsploraSceneView.h"

static void *ORSMainViewControllerKVOContext = &ORSMainViewControllerKVOContext;

@interface ORSMainViewController ()

@property (nonatomic, weak) IBOutlet ORSEsploraSceneView *sceneView;

@property (nonatomic, strong, readwrite) ORSBoardController *boardController;

@end

@implementation ORSMainViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		self.boardController = [[ORSBoardController alloc] init];
	}
	return self;
}

- (void)dealloc
{
	self.boardController = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if (context != ORSMainViewControllerKVOContext) {
		return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
	if ([keyPath isEqualToString:@"orientation"]) {
		self.sceneView.orientation = self.boardController.orientation;
	}
	
	if ([keyPath isEqualToString:@"lightLevel"]) {
		self.sceneView.lightLevel = (float)self.boardController.lightLevel / 255.0;
	}
	
	if ([keyPath isEqualToString:@"sliderValue"]) {
		CGFloat hue = self.boardController.sliderValue / 255.0;
		self.sceneView.boardColor = [NSColor colorWithCalibratedHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
	}
}

#pragma mark - Properties

- (ORSSerialPortManager *)serialPortManager { return [ORSSerialPortManager sharedSerialPortManager]; }

- (void)setBoardController:(ORSBoardController *)boardController
{
	if (boardController != _boardController) {
		[_boardController removeObserver:self forKeyPath:@"orientation" context:ORSMainViewControllerKVOContext];
		[_boardController removeObserver:self forKeyPath:@"lightLevel" context:ORSMainViewControllerKVOContext];
		[_boardController removeObserver:self forKeyPath:@"sliderValue" context:ORSMainViewControllerKVOContext];
		
		_boardController = boardController;
		
		[_boardController addObserver:self forKeyPath:@"orientation" options:NSKeyValueObservingOptionInitial context:ORSMainViewControllerKVOContext];
		[_boardController addObserver:self forKeyPath:@"lightLevel" options:NSKeyValueObservingOptionInitial context:ORSMainViewControllerKVOContext];
		[_boardController addObserver:self forKeyPath:@"sliderValue" options:NSKeyValueObservingOptionInitial context:ORSMainViewControllerKVOContext];
	}
}

@end
