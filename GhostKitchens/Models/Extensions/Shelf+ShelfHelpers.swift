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
	func shelfDescription(orderDecayInfo:[String : Float]) -> String  {

		var printedShelf = ""
		printedShelf += "\n" + name
		printedShelf += "\n" + "Capacity: " + String(capacity)
		printedShelf += "\n" + "Order Count: " + String(currentOrders.count)
		printedShelf += "\n" + "Shelf Decay Modifier: " + String(self.shelfDecayModifier)
		printedShelf += "\n" + "Orders:"

		currentOrders.forEach { (order) in
			printedShelf += order.description(withDecay: orderDecayInfo[order.id])
		}
		
		return printedShelf
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
	static func orders(fromShelves: [Shelf]) -> [Order] {
		
		var orders:[Order] = []
		fromShelves.forEach { (shelf) in
			orders.append(contentsOf: shelf.currentOrders)
		}
		return orders
	}
}

