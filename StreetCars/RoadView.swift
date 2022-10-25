//
//  RoadView.swift
//  StreetCars
//
//  Created by Marina Khort on 23.04.2021.
//

import SpriteKit
import GameplayKit

class RoadView: SKNode, SKPhysicsContactDelegate {
	
	let sceneView: GameScene
	
	
	var car = SKSpriteNode()
	var trafficItem : SKSpriteNode!
	var policeCar: SKSpriteNode?
	var towTruck: SKSpriteNode?
	var button: SKSpriteNode!
	var oil: SKSpriteNode!
	
	var trafficItemName: String
	var canMove = false
	var carToMoveAtSide = true
	var carAtSide = false
	var stopSide = true
	var width: CGFloat
	var height: CGFloat
	var carMinX: CGFloat!
	var carMaxX: CGFloat!
	
	var calc: Calculations
	var logger: Logger
	
	var counter: Int = 0
	let fuelLabel = SKLabelNode(fontNamed: "SFPro-Bold")
	var fuel = 30 {
		didSet {
			fuelLabel.text = "fuel left: \(fuel)"
		}
	}
	var isStopped = false
	var carHits = false
	var nofuel = false
	var isOil = false
	
	init(
		name: String,
		trafficItemName: String,
		width: CGFloat,
		height: CGFloat,
		position: CGPoint,
		logger: Logger
	) {
		self.width = width
		self.height = height
		self.trafficItemName = trafficItemName
		self.sceneView = GameScene()
		self.calc = Calculations(size: CGSize(width: width, height: height), position: position)
		self.logger = logger
		super.init()
		self.name = name
		self.position = position
//		logger.deleteTextInFile()
		createRoad()
		createCar()
		setLabel()
		addButtonForTowTruck()
		
		carMinX = calc.calcCarMinPosition()
		carMaxX = calc.calcCarMaxPosition()
	
		Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector(RoadView.createRoadStrip), userInfo: nil, repeats: true )
		Timer.scheduledTimer(timeInterval:TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 3)), target: self, selector: #selector(RoadView.addTrafficCars), userInfo: nil, repeats: true)
		Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(RoadView.reducefuel), userInfo: nil, repeats: true)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	func createRoad() {
		let road = SKSpriteNode(imageNamed: "road")
		road.size = CGSize(width: width, height: height)
		road.position = CGPoint(x: 0, y: 0)
		road.zPosition = -1
		addChild(road)

	}
	
	func createCar() {
		car = SKSpriteNode(imageNamed: "yellowCar")
		car.zPosition = 10
		car.size = CGSize(width: 65, height: 126)
		car.position = calc.carPosition()
		car.physicsBody = SKPhysicsBody(texture: car.texture!, size: car.size)
		car.physicsBody?.linearDamping = 0
		car.physicsBody?.categoryBitMask = 0
		car.physicsBody?.contactTestBitMask = 1
		car.physicsBody?.collisionBitMask = 0
		
		addChild(car)
	}
	
	func setLabel() {
		fuelLabel.zPosition = 100
		fuelLabel.fontSize = 40
		fuelLabel.position = calc.fuelLabelPosition()
		addChild(fuelLabel)
		fuel = 30
	}
	
	@objc func createRoadStrip() {
		if isStopped {
			return
		}
		let roadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
		roadStrip.strokeColor = SKColor.white
		roadStrip.fillColor = SKColor.white
		roadStrip.alpha = 0.4
		roadStrip.name = "roadStrip"
		roadStrip.zPosition = 10
		roadStrip.position = calc.calcRoadStripPos()
		addChild(roadStrip)
	}
	
	
	func showRoadItems() {
		if isStopped {
			return
		}
		enumerateChildNodes(withName: "roadStrip", using: { (roadStrip, stop) in
			let strip = roadStrip as! SKShapeNode
			if (strip.position.y < -700) {
				strip.removeFromParent()
			} else {
				strip.position.y -= 30
			}
		})
		
		enumerateChildNodes(withName: trafficItemName, using: { (carItem, stop) in
			let car = carItem as! SKSpriteNode
			if (car.position.y < -700) {
				car.removeFromParent()
			} else {
				car.position.y -= 15
			}
		})
		
//		enumerateChildNodes(withName: "policeCar", using: { (carItem, stop) in
//			let car = carItem as! SKSpriteNode
//			if (self.carHits == false && self.isStopped == false) {
//				car.removeFromParent()
//			}
//		})
	}
	
	
	
	func carHits(_ node: SKNode) {
		carHits = true
		if let particles = SKEmitterNode(fileNamed: "Explosion.sks") {
			particles.name = "explosion"
			particles.position = car.position
			particles.particleSize = CGSize(width: 80, height: 80)
			particles.zPosition = 50
			addChild(particles)
		}
		logger.writeLog(text: "\(String(describing: name!)): BOOOM!!! Cars hit.")
		Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(RoadView.removeParticles), userInfo: nil, repeats: false )
		
	}
	
	@objc func removeParticles() {
		children
			.filter{ $0.name == "explosion" }
			.forEach{ $0.removeFromParent()}
	}
	
	@objc func reducefuel() {
		if isStopped {
			return
		}
		
		fuel -= 1
		if fuel == 5 {
			logger.writeLog(text: "\(String(describing: name!)): Fuel is almost out - \(fuel)")
			nofuel = true
			pauseTraffic()
			refuel()
			nofuel = false
		}
		
		if fuel == 20 {
			oilLeaked()
		}
	}
	
	
	func removeTrafficItems() {
		for child in children {
			if child.name == trafficItemName {
				child.removeFromParent()
			}
		}
	}
	
	
	func moveCar(oneSide:Bool){
		if oneSide{
			car.position.x -= 20
			if car.position.x < carMinX {
				car.position.x = carMinX
			}
		}else{
			car.position.x += 20
			if car.position.x > carMaxX {
				car.position.x = carMaxX
			}
		}
	}
	
	@objc func addTrafficCars(){
		if isStopped {
			return
		}
		let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
		switch Int(randonNumber) {
		case 1...8:
			trafficItem = SKSpriteNode(imageNamed: trafficItemName)
			break
		default:
			trafficItem = SKSpriteNode(imageNamed: trafficItemName)
		}
		trafficItem.zPosition = 10
		let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
		switch Int(randomNum) {
		case 1...4:
			trafficItem.position.x = calc.calcCarMaxPosition()
			break
		case 5...10:
			trafficItem.position.x = calc.calcCarMinPosition()
			break
		default:
			trafficItem.position.x = calc.calcCarMaxPosition()
		}
		trafficItem.name = trafficItemName
		trafficItem.position.y = calc.trafficItemPosition()
		trafficItem.size = CGSize(width: 65, height: 126)
		trafficItem.physicsBody = SKPhysicsBody(texture: trafficItem.texture!, size: trafficItem.size)
		trafficItem.physicsBody?.linearDamping = 0
		trafficItem.physicsBody?.categoryBitMask = 1
		trafficItem.physicsBody?.collisionBitMask = 0
		trafficItem.physicsBody?.affectedByGravity = false
		
		addChild(trafficItem)
		logger.writeLog(text: "\(String(describing: name!)): Traffic cars add at positions : \(trafficItem.position)")

	}

	func pauseTraffic() {
		isStopped = true
//		logger.writeLog(text: "\(String(describing: name!)): Traffic is paused")
	}
	
	
	func policeCarArrives() {
		if carHits == true {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				if self.policeCar == nil {
					self.policeCar = SKSpriteNode(imageNamed: "policeCar")
					self.policeCar!.zPosition = 20
					self.policeCar!.name = "policeCar"
					self.policeCar!.position = CGPoint(x: self.car.position.x, y: self.car.position.y - 127)
					self.policeCar!.size = CGSize(width: 65, height: 126)
					self.addChild(self.policeCar!)
				}
			}
			logger.writeLog(text: "\(String(describing: name!)): The police car arrives")
		}
	}
	
	func policeCarGoAway() {
		carHits = false
		isStopped = false
		let move = SKAction.moveTo(y: car.position.y - 130, duration: 0)
		trafficItem.run(move)
		logger.writeLog(text: "\(String(describing: self.name!)): Car continue to move")
		policeCar?.removeFromParent()
		policeCar = nil
	}
	
	func refuel() {
		if nofuel == true {
			let fuelStation = SKSpriteNode(imageNamed: "fuelStation")
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				fuelStation.zPosition = 20
				fuelStation.name = "fuelStation"
				fuelStation.position = CGPoint(x: 160, y: 180)
				fuelStation.size = CGSize(width: 60, height: 120)
				self.addChild(fuelStation)
				self.pauseTraffic()
			}
			let moveCar = SKAction.move(to: CGPoint(x: 100, y: 180), duration: 6)
			self.car.run(moveCar)
			logger.writeLog(text: "\(String(describing: name!)): Car moves to the gas station")
			removeTrafficItems()
            
		}
			DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
				self.fuel += 20
				let moveCar = SKAction.move(to: CGPoint(x: 75, y: -222), duration: 1)
				self.car.run(moveCar)
				self.isStopped = false
			}
		logger.writeLog(text: "\(String(describing: name!)): Car has been refueled")
	}
	
	
	func oilLeaked() {
		oil = SKSpriteNode(imageNamed: "oil")
		oil.zPosition = 4
		oil.position = car.position
		oil.size = CGSize(width: 100, height: 150)
		addChild(oil)
		isOil = true
		logger.writeLog(text: "\(String(describing: name!)): Alarm, oil is out")
		pauseTraffic()
		removeTrafficItems()
		towTruckArrives()
	}
	
	func addButtonForTowTruck() {
		button = SKSpriteNode(imageNamed: "button")
		button.position = calc.buttonPosition()
		button.zPosition = 50
		button.name = "button"
		self.addChild(button)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if touch == touches.first {
				let location = touch.location(in: self)
				let touchedNode = atPoint(location)
				if touchedNode.name == "button" {
					print("touch")
				}
			}
		}
	}
	
	func towTruckArrives() {
		if isOil == true {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				self.towTruck = SKSpriteNode(imageNamed: "towTruck")
				self.towTruck!.zPosition = 5
				self.towTruck!.name = "towTruck"
				self.towTruck!.position = CGPoint(x: self.car.position.x, y: self.car.position.y + 700)
				self.towTruck!.size = CGSize(width: 65, height: 176)
				self.addChild(self.towTruck!)
				let moveTruck = SKAction.move(to: CGPoint(x: self.car.position.x, y: self.car.position.y + 127), duration: 1)
				self.towTruck?.run(moveTruck)
				self.logger.writeLog(text: "\(String(describing: self.name!)): Tow truck arrives")
				self.carLeavesWithTruck()
			}
		}
	}
	
	func carLeavesWithTruck() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			let carMovesOnTruck = SKAction.moveTo(y: (self.towTruck?.position.y)! - 50, duration: 1)
			self.car.run(carMovesOnTruck)
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
				let moveWithTruck = SKAction.moveTo(y: self.height, duration: 3)
				let moveTruckWithCar = SKAction.moveTo(y: self.height, duration: 3)
				self.car.run(moveWithTruck)
				self.towTruck?.run(moveTruckWithCar)
				self.logger.writeLog(text: "\(String(describing: self.name!)): Continue moving")
				DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
					self.oil.removeFromParent()
					self.isStopped = false
					self.isOil = false
					self.car.position = self.calc.carPosition()
//					self.createCar()
					self.logger.writeLog(text: "\(String(describing: self.name!)): Continue moving")

				}
			}
		}
	}
}
