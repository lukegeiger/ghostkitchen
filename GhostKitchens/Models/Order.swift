//
//  Order.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: Order

struct Order: Decodable {

	let id: String /// Unique ID
	let name: String /// Name of the order
	let temp: ShelfTemperature /// Preferred shelf storage temperature
	let shelfLife: Int /// Shelf wait max duration (seconds)
	let decayRate: Float /// Value deterioration modifier
}

// MARK: Equatable

extension Order: Equatable {
    static func == (lhs: Order, rhs: Order) -> Bool { return lhs.id == rhs.id}
}

// MARK: CustomStringConvertible

extension Order {
	
	func printWithDecay(decay : Float?) {
//		if let decay = decay {
//			print(self.description + ", decay: \(decay):")
//		}
//		print(self.description + ", decay: 1")
	}
}
