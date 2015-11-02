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
		self.boardController.addObserver(self, forKeyPath: "x", options: NSKeyValueObservingOptions.Initial, context: nil)
		self.boardController.addObserver(self, forKeyPath: "y", options: NSKeyValueObservingOptions.Initial, context: nil)
		self.boardController.addObserver(self, forKeyPath: "z", options: NSKeyValueObservingOptions.Initial, context: nil)
		self.boardController.addObserver(self, forKeyPath: "lightLevel", options: NSKeyValueObservingOptions.Initial, context: nil)
		self.boardController.addObserver(self, forKeyPath: "sliderValue", options: NSKeyValueObservingOptions.Initial, context: nil)
	}
	
	deinit {
		self.boardController.removeObserver(self, forKeyPath: "x")
		self.boardController.removeObserver(self, forKeyPath: "y")
		self.boardController.removeObserver(self, forKeyPath: "z")
		self.boardController.removeObserver(self, forKeyPath: "lightLevel")
		self.boardController.removeObserver(self, forKeyPath: "sliderValue")
	}
	
	// MARK: KVO
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if object as? BoardController != self.boardController {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
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
	
	dynamic let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
	dynamic let boardController = BoardController()
	
	@IBOutlet var sceneView: EsploraSceneView?
}

