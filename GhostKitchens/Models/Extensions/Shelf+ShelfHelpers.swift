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
	
    /**
		Lets you know if the shelfs orders are at or above capacity.

     - Returns: A bool If the shelf is full or not.
     */
	func isFull() -> Bool {
		
		return self.currentOrders.count >= self.capacity
	}
	
    /**
		Prints the shelf contents
     */
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
	
    /**
     Lets you know all the orders that are on the passed in shelves.

     - Parameters:
        - fromShelves: All the shelves in which you wish to know the orders they contain

     - Returns: An array of all the orders currently on the shelves
     */
	static func orders(fromShelves:[Shelf]) -> [Order] {
		
		var orders:[Order] = []
		fromShelves.forEach { (shelf) in
			orders.append(contentsOf: shelf.currentOrders)
		}
		return orders
	}
}

