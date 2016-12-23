// Playground - noun: a place where people can play

import Cocoa
import SceneKit
import XCPlayground

class EsploraSceneView: SCNView {
	
	override init(frame: NSRect, options: [NSObject : AnyObject]?) {
		super.init(frame: frame, options: options)
		setupScene()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupScene()
	}
	
	func setupScene() {
		
		self.autoenablesDefaultLighting = true
		self.backgroundColor = NSColor.blueColor()
		
		let scene = SCNScene()
		
		let camera = SCNCamera()
		camera.xFov = 10
		camera.yFov = 45
		
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3Make(0, 0, 50)
		scene.rootNode.addChildNode(cameraNode)
		
		let directionalLight = SCNLight()
		directionalLight.type = SCNLightTypeSpot
		directionalLight.color = NSColor.whiteColor()
		directionalLight.castsShadow = true
		self.light = directionalLight
		let directionalLightNode = SCNNode()
		directionalLightNode.position = SCNVector3Make(0, 20, 50)
		directionalLightNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, -0.35)
		directionalLightNode.light = directionalLight
		scene.rootNode.addChildNode(directionalLightNode)
		
		let ambientLight = SCNLight()
		ambientLight.type = SCNLightTypeAmbient
		ambientLight.color = NSColor(calibratedWhite: 0.4, alpha: 1.0)
		ambientLight.castsShadow = true
		self.light = ambientLight
		let ambientLightNode = SCNNode()
		ambientLightNode.light = ambientLight
		scene.rootNode.addChildNode(ambientLightNode)
		
		self.scene = scene
		
		self.loadBackground()
		self.loadObject()
		self.orientation = (0.0, 1.0, 1.0)
	}
	
	func loadBackground() {
		let backgroundRect = NSOffsetRect(self.bounds, -NSWidth(self.bounds)/2.0, -NSHeight(self.bounds)/2.0)
		let background = SCNShape(path: NSBezierPath(rect: backgroundRect), extrusionDepth: 0.0)
		let material = SCNMaterial()
		material.diffuse.contents = NSColor.darkGrayColor()
		material.specular.contents = NSColor.darkGrayColor()
		material.shininess = 0.2
		background.materials = [material]
		
		let backgroundNode = SCNNode(geometry: background)
		backgroundNode.position = SCNVector3Make(0, 0, -20)
		
		self.scene?.rootNode.addChildNode(backgroundNode)
	}
	
	func loadObject () {
		let bezierPath = NSBezierPath(roundedRect: NSMakeRect(-15, -4, 30, 8), xRadius: 4, yRadius: 4)
		bezierPath.flatness = 0
		let object = SCNShape(path: bezierPath, extrusionDepth: 0.5)
		let objectNode = SCNNode(geometry: object)
		
		let material = SCNMaterial()
		material.diffuse.contents = NSColor(calibratedHue: 0.546, saturation: 1.0, brightness: 0.476, alpha: 1.0)
		material.specular.contents = NSColor.whiteColor()
		material.shininess = 0.5
		object.materials = [material]
		
		self.scene?.rootNode.addChildNode(objectNode)
		self.objectNode = objectNode
	}
	
	// MARK: Properties
	
	var orientation: (x: Double, y: Double, z: Double)? {
		didSet {
			if let orientation = self.orientation {
				let y = orientation.y
				let x = orientation.x
				let z = orientation.z
				let roll: CGFloat = CGFloat(atan2(x, z))
				let pitch = CGFloat(atan2(y, sqrt(x * x + z * z)) + M_PI_2)
				
				var transform = CATransform3DMakeRotation(roll, 0.0, 0.0, 1.0)
				transform = CATransform3DRotate(transform, pitch, 1.0, 0.0, 0.0)
				self.objectNode?.transform = transform
			}
		}
	}
	
	var lightLevel: Float = 1.0 {
		didSet {
			self.light?.color = NSColor(calibratedWhite: CGFloat(lightLevel), alpha: CGFloat(1.0))
		}
	}
	
	private var objectNode: SCNNode?
	private var light: SCNLight?
}

let frame = NSMakeRect(0, 0, 800, 800)
let sceneView = EsploraSceneView(frame: frame, options: nil)

XCPShowView("sceneView", sceneView)
