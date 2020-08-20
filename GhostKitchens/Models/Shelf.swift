//
//  Shelf.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: ShelfTemperature

enum ShelfTemperature: String,Decodable {
	
	case any
	case hot
	case cold
	case frozen
}

// MARK: Shelf

final class Shelf {
	
	let name: String
	let allowedTemperature: ShelfTemperature
	let capacity: Int
	let shelfDecayModifier: Int
	
	var currentOrders:[Order]

	init(name: String,
		 allowedTemperature: ShelfTemperature,
		 capacity: Int,
		 currentOrders: [Order] = []) {
		
		self.name = name
		self.allowedTemperature = allowedTemperature
		self.capacity = capacity
		self.currentOrders = currentOrders
		self.shelfDecayModifier = (allowedTemperature == .any) ? 2:1
	}
}
