//
//  Order.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: Order

class Order: Decodable {

	let id: String /// Unique ID
	let name: String /// Name of the order
	let temp: ShelfTemperature /// Preferred shelf storage temperature
	let shelfLife: Int /// Shelf wait max duration (seconds)
	let decayRate: Float /// Value deterioration modifier
	
	var decay: Float? /// Represents how much this order has left to live. > 0 is good  <= 0 is bad.
	
	init(id: String,
		 name: String,
		 temp: ShelfTemperature,
		 shelfLife: Int,
		 decayRate: Float,
		 decay: Float? = nil) {
		
		self.id = id
		self.name = name
		self.temp = temp
		self.shelfLife = shelfLife
		self.decayRate = decayRate
		self.decay = decay
	}
}

// MARK: Equatable

extension Order: Equatable {
	
    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: CustomStringConvertible

/**
	This is implemented so when orders get printed in the debugger it will print its properties and appear as something like this

	Order(id: a2b13869-6b7e-4e35-8e11-fa9889d24073
	name: Vanilla Ice Cream,
	temp: frozen,
	shelfLife: 310,
	decayRate: 0.35 ,
	decay: Optional(0.98258066)

	Instead of GhostKitchen.Order
 */

extension Order: CustomStringConvertible {
	
	var description: String {
		return "\("Order")(id: \(id) name: \(name), temp: \(temp), shelfLife: \(shelfLife), decayRate: \(decayRate) , decay: \(String(describing: decay))"
	}	
}
