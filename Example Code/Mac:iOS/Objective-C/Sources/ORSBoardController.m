//
//  ORSBoardController.m
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 11/1/15.
//  Copyright © 2015 Open Reel Software. All rights reserved.
//

#import "ORSBoardController.h"
#import "ORSOrientation.h"
@import ORSSerial;

typedef NS_ENUM(NSInteger, ORSRequestType) {
	ORSOrientationRequest = 1,
	ORSLightLevelRequest,
	ORSSliderRequest,
};

@interface ORSBoardController () <ORSSerialPortDelegate>

@property (nonatomic, strong, readwrite) ORSOrientation *orientation;
@property (nonatomic, readwrite) NSInteger lightLevel;
@property (nonatomic, readwrite) NSInteger sliderValue;

@property (nonatomic, strong) NSTimer *pollingTimer;

@end

@implementation ORSBoardController

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self startPolling];
	}
	return self;
}

#pragma mark - Private

- (ORSOrientation *)positionFromResponseData:(NSData *)data
{
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if (dataString.length < 9) return nil;
	if (![dataString hasPrefix:@"all"] || ![dataString hasSuffix:@";"]) return nil;
	
	dataString = [dataString substringWithRange:NSMakeRange(3, dataString.length-4)];
	
	NSArray *components = [dataString componentsSeparatedByString:@":"];
	if (components.count < 3) return nil;
	
	double x = [components[0] doubleValue] / 200.0;
	double y = [components[1] doubleValue] / 200.0;
	double z = [components[2] doubleValue] / 200.0;
	return [[ORSOrientation alloc] initWithX:x y:y z:z];
}

- (NSNumber *)lightLevelFromResponseData:(NSData *)data
{
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if (dataString.length < 7) return nil;
	if (![dataString hasPrefix:@"light"] || ![dataString hasSuffix:@";"]) return nil;
	
	return @([[dataString substringWithRange:NSMakeRange(5, dataString.length-6)] integerValue]);
}

- (NSNumber *)sliderValueFromResponseData:(NSData *)data
{
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if (dataString.length < 8) return nil;
	if (![dataString hasPrefix:@"slider"] || ![dataString hasSuffix:@";"]) return nil;
	
	return @([[dataString substringWithRange:NSMakeRange(6, dataString.length-7)] integerValue]);
}

#pragma Polling

- (void)poll:(NSTimer *)timer
{
	if (!self.port.isOpen) return;
	if (self.port.pendingRequest != nil) return; // Wait until current request is finished
	
	ORSSerialPacketDescriptor *orientationResponseDescriptor =
	[[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:20 userInfo:nil responseEvaluator:^BOOL(NSData *data) {
		return [self positionFromResponseData:data] != nil;
	}];
	ORSSerialRequest *orientationRequest =
	[ORSSerialRequest requestWithDataToSend:[@"?all;" dataUsingEncoding:NSASCIIStringEncoding]
								   userInfo:@(ORSOrientationRequest)
							timeoutInterval:0.2
						 responseDescriptor:orientationResponseDescriptor];
	
	ORSSerialPacketDescriptor *lightResponseDescriptor =
	[[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:10 userInfo:nil responseEvaluator:^BOOL(NSData *data) {
		return [self lightLevelFromResponseData:data] != nil;
	}];
	ORSSerialRequest *lightRequest =
	[ORSSerialRequest requestWithDataToSend:[@"?light;" dataUsingEncoding:NSASCIIStringEncoding]
								   userInfo:@(ORSLightLevelRequest)
							timeoutInterval:0.2
						 responseDescriptor:lightResponseDescriptor];
	
	ORSSerialPacketDescriptor *sliderResponseDescriptor =
	[[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:10 userInfo:nil responseEvaluator:^BOOL(NSData *data) {
		return [self sliderValueFromResponseData:data] != nil;
	}];
	ORSSerialRequest *sliderRequest =
	[ORSSerialRequest requestWithDataToSend:[@"?slider;" dataUsingEncoding:NSASCIIStringEncoding]
								   userInfo:@(ORSSliderRequest)
							timeoutInterval:0.2
						 responseDescriptor:sliderResponseDescriptor];
	
	
	[self.port sendRequest:orientationRequest];
	[self.port sendRequest:lightRequest];
	[self.port sendRequest:sliderRequest];
}

- (void)startPolling
{
	self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(poll:) userInfo:nil repeats:YES];
}

- (void)stopPolling
{
	self.pollingTimer = nil;
}

#pragma mark - ORSSerialPortDelegate

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveResponse:(NSData *)responseData toRequest:(ORSSerialRequest *)request
{
	ORSRequestType requestType = [request.userInfo integerValue];
	switch (requestType) {
		case ORSOrientationRequest:
			self.orientation = [self positionFromResponseData:responseData];
			break;
		case ORSLightLevelRequest:
			self.lightLevel = [[self lightLevelFromResponseData:responseData] integerValue];
			break;
		case ORSSliderRequest:
			self.sliderValue = [[self sliderValueFromResponseData:responseData] integerValue];
			break;
		default:
			NSLog(@"Unexpected request type");
			break;
	}
}

- (void)serialPort:(ORSSerialPort *)serialPort requestDidTimeout:(ORSSerialRequest *)request
{
	NSLog(@"request timed out %@", request);
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
	self.port = nil;
}

#pragma mark - Properties


- (void)setPort:(ORSSerialPort *)port
{
	if (port != _port) {
		_port.delegate = nil;
		_port = port;
		
		_port.baudRate = @57600;
		_port.delegate = self;
		_port.RTS = YES;
		[_port open];
	}
}

- (void)setPollingTimer:(NSTimer *)pollingTimer
{
	if (pollingTimer != _pollingTimer) {
		[_pollingTimer invalidate];
		_pollingTimer = pollingTimer;
	}
}

@end
