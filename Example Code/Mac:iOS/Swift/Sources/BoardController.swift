//
//  BoardController.swift
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 2/3/15.
//  Copyright (c) 2015 Open Reel Software. All rights reserved.
//

import ORSSerial

enum RequestType: Int {
	case OrientationRequest = 1
	case LightLevelRequest
	case SliderRequest
}

class BoardController: NSObject, ORSSerialPortDelegate {
	
	override init() {
		super.init()
		startPolling()
	}
	
	convenience init(serialPort: ORSSerialPort) {
		self.init()
		self.port = serialPort
	}
	
	// MARK: Response Parsing
	
	func positionFromResponseData(data: NSData?) -> (x: Double, y: Double, z: Double)? {
		guard let d = data,
			var dataString = NSString(data: d, encoding: NSASCIIStringEncoding) else { return nil }
		
		if dataString.length < 9 { return nil }
		if !dataString.hasPrefix("all") || !dataString.hasSuffix(";") { return nil }
		
		dataString = dataString.substringWithRange(NSMakeRange(3, dataString.length-4))
		
		let components = dataString.componentsSeparatedByString(":")
		
		return (Double(components[0])! / 200.0, Double(components[1])! / 200.0, Double(components[2])! / 200.0)
	}
	
	func lightLevelFromResponseData(data: NSData?) -> Int? {
		guard let d = data,
			dataString = NSString(data: d, encoding: NSASCIIStringEncoding) else { return nil }
		
		if dataString.length < 7 { return nil }
		if !dataString.hasPrefix("light") || !dataString.hasSuffix(";") { return nil }
		
		return Int(dataString.substringWithRange(NSMakeRange(5, dataString.length-6)))
	}
	
	func sliderValueFromResponseData(data: NSData?) -> Int? {
		guard let d = data,
			dataString = NSString(data: d, encoding: NSASCIIStringEncoding) else { return nil }
		
		if dataString.length < 8 { return nil }
		if !dataString.hasPrefix("slider") || !dataString.hasSuffix(";") { return nil }
		
		return Int(dataString.substringWithRange(NSMakeRange(6, dataString.length-7)))
	}
	
	// MARK: Polling
	
	func poll(timer: NSTimer) {
		if let port = self.port {
			if !port.open { return; }
			if port.pendingRequest != nil { return; } // Wait until current request is finished
			
			let orientationResponseDescriptor = ORSSerialPacketDescriptor(maximumPacketLength: 8, userInfo: nil) {
				return self.positionFromResponseData($0) != nil
			}
			let orientationRequest = ORSSerialRequest(dataToSend: "?all;".dataUsingEncoding(NSASCIIStringEncoding)!,
				userInfo: RequestType.OrientationRequest.rawValue,
				timeoutInterval: 1.0,
				responseDescriptor: orientationResponseDescriptor)
			
			let lightResponseDescriptor = ORSSerialPacketDescriptor(maximumPacketLength: 10, userInfo: nil) {
				return self.lightLevelFromResponseData($0) != nil
			}
			let lightRequest = ORSSerialRequest(dataToSend: "?light;".dataUsingEncoding(NSASCIIStringEncoding)!,
				userInfo: RequestType.LightLevelRequest.rawValue,
				timeoutInterval: 1.0,
				responseDescriptor: lightResponseDescriptor)
			
			let sliderResponseDescriptor = ORSSerialPacketDescriptor(maximumPacketLength: 11, userInfo: nil) {
				return self.sliderValueFromResponseData($0) != nil
			}
			let sliderRequest = ORSSerialRequest(dataToSend: "?slider;".dataUsingEncoding(NSASCIIStringEncoding)!,
				userInfo: RequestType.SliderRequest.rawValue,
				timeoutInterval: 1.0,
				responseDescriptor: sliderResponseDescriptor)
			
			port.sendRequest(orientationRequest)
			port.sendRequest(lightRequest)
			port.sendRequest(sliderRequest)
		}
	}
	
	func startPolling() {
		self.pollingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "poll:", userInfo: nil, repeats: true)
	}
	
	func stopPolling () {
		self.pollingTimer = nil
	}
	
	// MARK: ORSSerialPortDelegate
	
	func serialPort(_: ORSSerialPort, didReceiveResponse responseData: NSData, toRequest request: ORSSerialRequest) {
		
		guard let requestRawValue = request.userInfo?.integerValue,
			requestType = RequestType(rawValue: requestRawValue) else {
				return
		}
		
		switch requestType {
		case .OrientationRequest:
			if let position = self.positionFromResponseData(responseData) {
				self.orientation = position
			}
		case .LightLevelRequest:
			if let lightLevel = self.lightLevelFromResponseData(responseData) {
				self.lightLevel = lightLevel
			}
		case .SliderRequest:
			if let sliderValue = self.sliderValueFromResponseData(responseData) {
				self.sliderValue = sliderValue
			}
		}
	}
	
	func serialPort(serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
		print("request timed out \(request)")
	}
	
	func serialPortWasRemovedFromSystem(port: ORSSerialPort) {
		if port != self.port { return }
		self.port = nil
	}
	
	// MARK: Properties
	
	private(set) internal var orientation: (x: Double, y: Double, z: Double) {
		get {
			return (self.x, self.y, self.z)
		}
		set {
			self.x = newValue.x
			self.y = newValue.y
			self.z = newValue.z
		}
	}
	dynamic var x: Double = 0
	dynamic var y: Double = 0
	dynamic var z: Double = 0
	
	dynamic var lightLevel: Int = 0
	dynamic var sliderValue: Int = 0
	
	dynamic var port: ORSSerialPort? {
		didSet {
			port?.baudRate = 9600
			port?.delegate = self
			port?.open()
		}
	}
	
	private var pollingTimer: NSTimer? {
		willSet {
			self.pollingTimer?.invalidate()
		}
	}
	
}
