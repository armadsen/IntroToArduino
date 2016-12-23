//
//  BoardController.swift
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 2/3/15.
//  Copyright (c) 2015 Open Reel Software. All rights reserved.
//

import ORSSerial

enum RequestType: Int {
	case orientationRequest = 1
	case lightLevelRequest
	case sliderRequest
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
	
	private func notNil<T,U>(_ function: @escaping (T) -> U?) -> (T) -> Bool {
		return { (input: T) in
			function(input) != nil
		}
	}
	
	func positionFromResponseData(_ data: Data?) -> (x: Double, y: Double, z: Double)? {
		guard let data = data,
			var dataString = String(data: data, encoding: .ascii) else {
				return nil
		}
		
		let length = dataString.characters.count
		if length < 9 { return nil }
		if !dataString.hasPrefix("all") || !dataString.hasSuffix(";") { return nil }
		
		let dataRange = dataString.index(dataString.startIndex, offsetBy: 3)..<dataString.index(before: dataString.endIndex)
		dataString = dataString.substring(with: dataRange)
		
		let components = dataString.components(separatedBy: ":")
		
		return (Double(components[0])! / 200.0, Double(components[1])! / 200.0, Double(components[2])! / 200.0)
	}
	
	func lightLevelFromResponseData(_ data: Data?) -> Int? {
		guard let data = data,
			let dataString = NSString(data: data, encoding: String.Encoding.ascii.rawValue) else {
				return nil
		}
		
		if dataString.length < 7 { return nil }
		if !dataString.hasPrefix("light") || !dataString.hasSuffix(";") { return nil }
		
		return Int(dataString.substring(with: NSMakeRange(5, dataString.length-6)))
	}
	
	func sliderValueFromResponseData(_ data: Data?) -> Int? {
		guard let data = data,
			let dataString = NSString(data: data, encoding: String.Encoding.ascii.rawValue) else {
				return nil
		}
		
		if dataString.length < 8 { return nil }
		if !dataString.hasPrefix("slider") || !dataString.hasSuffix(";") { return nil }
		
		return Int(dataString.substring(with: NSMakeRange(6, dataString.length-7)))
	}
	
	// MARK: Polling
	
	func poll(_ timer: Timer) {
		if let port = self.port {
			if !port.isOpen { return; }
			if port.pendingRequest != nil { return; } // Wait until current request is finished
			
			let orientationResponse = ORSSerialPacketDescriptor(prefixString: "all", suffixString: ";", maximumPacketLength: 20, userInfo: nil)
			let orientationRequest = ORSSerialRequest(dataToSend: "?all;".data(using: .ascii)!,
				userInfo: RequestType.orientationRequest.rawValue,
				timeoutInterval: 1.0,
				responseDescriptor: orientationResponse)
			
			let lightResponse = ORSSerialPacketDescriptor(maximumPacketLength: 10, userInfo: nil, responseEvaluator: notNil(lightLevelFromResponseData))
			let lightRequest = ORSSerialRequest(dataToSend: "?light;".data(using: .ascii)!,
				userInfo: RequestType.lightLevelRequest.rawValue,
				timeoutInterval: 1.0,
				responseDescriptor: lightResponse)
			
			let sliderResponse = ORSSerialPacketDescriptor(maximumPacketLength: 10, userInfo: nil, responseEvaluator: notNil(sliderValueFromResponseData))
			let sliderRequest = ORSSerialRequest(dataToSend: "?slider;".data(using: .ascii)!,
				 userInfo: RequestType.sliderRequest.rawValue,
				timeoutInterval: 1.0,
				responseDescriptor: sliderResponse)

			port.send(orientationRequest)
			port.send(lightRequest)
			port.send(sliderRequest)
		}
	}
	
	func startPolling() {
		self.pollingTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(BoardController.poll(_:)), userInfo: nil, repeats: true)
	}
	
	func stopPolling () {
		self.pollingTimer = nil
	}
	
	// MARK: ORSSerialPortDelegate
	
	func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
		let requestType = RequestType(rawValue: (request.userInfo as AnyObject).intValue)!
		switch requestType {
		case .orientationRequest:
			if let position = self.positionFromResponseData(responseData) {
				self.orientation = position
			}
		case .lightLevelRequest:
			if let lightLevel = self.lightLevelFromResponseData(responseData) {
				self.lightLevel = lightLevel
			}
		case .sliderRequest:
			if let sliderValue = self.sliderValueFromResponseData(responseData) {
				self.sliderValue = sliderValue
			}
		}
	}

	func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
		print("request timed out \(request)")
	}

	func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
		if port != self.port { return }
		self.port = nil
	}
	
	// MARK: Properties
	
	fileprivate(set) internal var orientation: (x: Double, y: Double, z: Double) {
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
			port?.rts = true
			port?.open()
		}
	}
	
	fileprivate var pollingTimer: Timer? {
		willSet {
			self.pollingTimer?.invalidate()
		}
	}

}
