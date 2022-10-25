//
//  GameScene.swift
//  StreetCars
//
//  Created by Marina Khort on 21.04.2021.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
	var roads: [RoadView] = []
	var centerPoint : CGFloat!
	var canMove = false
	
    override func didMove(to view: SKView) {
		let logger = Logger()
		let width = self.size.width / 2
		let height = self.size.height
		print("Frame \(self.size.width) \(self.size.height)")
		
		let leftRoadPosition = CGPoint(x: width/2, y: height / 2)
		let rightRoadPosition = CGPoint(x: width + width/2, y: self.size.height/2)
		self.roads.append(RoadView(name: "Left road", trafficItemName: "greenCar", width: width, height: height, position: leftRoadPosition, logger: logger))
		self.roads.append(RoadView(name: "Right road", trafficItemName: "blackCar", width: width, height: height, position: rightRoadPosition, logger: logger) )
		self.roads.forEach({ addChild($0) })
		
		centerPoint = self.frame.size.width / self.frame.size.height
		
		physicsWorld.gravity = CGVector.zero
		physicsWorld.contactDelegate = self
		
//		let road1Thread = Thread.init(target: roads[0], selector: #selector(roads[0].drive), object: roads[0])
//		let road2Thread = Thread.init(target: roads[1], selector: #selector(roads[1].drive), object: nil)
//		road1Thread.start()
//		road2Thread.start()
    }
	
	
	override func update(_ currentTime: TimeInterval) {
		self.roads.forEach({
			if $0.isStopped {
				return
			}
			if canMove{
				$0.moveCar(oneSide: $0.carToMoveAtSide)
			} else {
				$0.moveCar(oneSide: $0.stopSide)
			}
			$0.showRoadItems()

		})
	}
	
	
	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node else {return}
		let road = nodeA.parent! as! RoadView
		if (road.carHits == true) {
			return
		}
		road.carHits(nodeA)
		road.pauseTraffic()
		road.policeCarArrives()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			road.policeCarGoAway()
//			road.carHits = false
//			road.isStopped = false
//			let move = SKAction.moveTo(y: road.car.position.y - 130, duration: 0)
//			road.trafficItem.run(move)
//			road.logger.writeLog(text: "\(String(describing: self.name!)): Car continue to move")
//			road.policeCar?.removeFromParent()
//			road.policeCar = nil
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches{
			let touchLocationRight = touch.location(in: roads[1])
			let touchLocationLeft = touch.location(in: roads[0])

			if touchLocationRight.x > centerPoint{
				if roads[1].carAtSide {
					roads[1].carAtSide = false
					roads[1].carToMoveAtSide = true
					roads[1].logger.writeLog(text: "Right road touched")
				}else{
					roads[1].carAtSide = true
					roads[1].carToMoveAtSide = false
				}
			} else if touchLocationLeft.x < centerPoint {
				if roads[0].carAtSide {
					roads[0].carAtSide = false
					roads[0].carToMoveAtSide = true
					roads[0].logger.writeLog(text: "Left road touched")
				}else{
					roads[0].carAtSide = true
					roads[0].carToMoveAtSide = false
				}

			}
			canMove = true

		}
	}
	
}
