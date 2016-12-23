//
//  MainViewController.swift
//  Esplora Accelerometer Demo
//
//  Created by Andrew Madsen on 2/2/15.
//  Copyright (c) 2015 Open Reel Software. All rights reserved.
//

import Cocoa
import ORSSerial

class MainViewController: NSViewController {
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.boardController.addObserver(self, forKeyPath: "x", options: NSKeyValueObservingOptions.initial, context: &KVOContext)
		self.boardController.addObserver(self, forKeyPath: "y", options: NSKeyValueObservingOptions.initial, context: &KVOContext)
		self.boardController.addObserver(self, forKeyPath: "z", options: NSKeyValueObservingOptions.initial, context: &KVOContext)
		self.boardController.addObserver(self, forKeyPath: "lightLevel", options: NSKeyValueObservingOptions.initial, context: &KVOContext)
		self.boardController.addObserver(self, forKeyPath: "sliderValue", options: NSKeyValueObservingOptions.initial, context: &KVOContext)
	}
	
	deinit {
		self.boardController.removeObserver(self, forKeyPath: "x", context: &KVOContext)
		self.boardController.removeObserver(self, forKeyPath: "y", context: &KVOContext)
		self.boardController.removeObserver(self, forKeyPath: "z", context: &KVOContext)
		self.boardController.removeObserver(self, forKeyPath: "lightLevel", context: &KVOContext)
		self.boardController.removeObserver(self, forKeyPath: "sliderValue", context: &KVOContext)
	}
	
	// MARK: KVO
	
	var KVOContext: Int = 0
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard context == &KVOContext,
			object as? BoardController == self.boardController else {
				super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
				return
		}
		
		if keyPath == "x" || keyPath == "y" || keyPath == "z" {
			self.sceneView?.orientation = self.boardController.orientation
			return
		}
		
		if keyPath == "lightLevel" {
			self.sceneView?.lightLevel = Float(self.boardController.lightLevel) / 255.0
		}
		
		if keyPath == "sliderValue" {
			let hue = CGFloat(self.boardController.sliderValue) / 255.0
			self.sceneView?.boardColor = NSColor(calibratedHue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
		}
	}
	
	// MARK: Properties
	
	dynamic let serialPortManager = ORSSerialPortManager.shared()
	dynamic let boardController = BoardController()
	
	@IBOutlet var sceneView: EsploraSceneView?
}

