//
//  Shelf+ShelfHelpers.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: Shelf Instance Helpers

extension Shelf {
	
	func isFull() -> Bool {
		
		return self.currentOrders.count >= self.capacity
	}
	
	func printShelf() {
		print(name)
		print("Capacity: " + String(capacity))
		print("Order Count: " + String(currentOrders.count))
		print("Shelf Decay Modifier: " + String(self.shelfDecayModifier))
		print("Orders: ", currentOrders)
	}
}

// MARK: Shelf Class Helpers

extension Shelf {
	
	static func orders(fromShelves:[Shelf]) -> [Order] {
		
		var orders:[Order] = []
		fromShelves.forEach { (shelf) in
			orders.append(contentsOf: shelf.currentOrders)
		}
		return orders
	}
}

