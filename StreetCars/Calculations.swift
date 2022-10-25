//
//  Calculations.swift
//  StreetCars
//
//  Created by Marina Khort on 23.04.2021.
//

import Foundation;
import SpriteKit
import GameplayKit

class Calculations {
	
	let size: CGSize
	let position: CGPoint
	
	init(size: CGSize, position: CGPoint) {
		self.size = size
		self.position = position
	}
	
	
	func calcRoadStripPos() -> CGPoint {
		let stripPosition = CGPoint(x: 0 , y: size.height)
		return stripPosition
	}
	
	func calcCarMinPosition () -> CGFloat {
		let carMinX = CGFloat(-(size.width / 5))
		return carMinX
	}
	
	func calcCarMaxPosition () -> CGFloat {
		let carMaxX = CGFloat(size.width / 6)
		return carMaxX
	}
	
	func carPosition() -> CGPoint {
		let carPosition = CGPoint(x: -(size.width / 5) , y: -(size.height)/6)

		return carPosition
	}
	
	func trafficItemPosition() -> CGFloat {
		let trafficItemPosition = CGFloat(size.height / 2)
		return trafficItemPosition
	}
	
	func fuelLabelPosition() -> CGPoint {
		let fuelLabelPosition = CGPoint(x: 0, y: -(size.height)/3)
		return fuelLabelPosition
	}
	
	func buttonPosition() -> CGPoint {
		let buttonPosition = CGPoint(x: 160, y: -(size.height)/3.5)
		return buttonPosition
	}
}
