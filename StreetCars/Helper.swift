//
//  Helper.swift
//  StreetCars
//
//  Created by Marina Khort on 22.04.2021.
//

import Foundation
import UIKit

struct ColliderType {
	static let CAR_COLLIDER : UInt32 = 0

	static let ITEM_COLLIDER : UInt32 = 1
	static let ITEM_COLLIDER_1 : UInt32 = 2
}

class Helper: NSObject {
	func randomBetweenTwoNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
		return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
	}
}
