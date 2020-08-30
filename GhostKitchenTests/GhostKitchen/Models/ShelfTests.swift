//
//  ShelfTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class ShelfTests: XCTestCase {
	
	func testIsFull() throws {

		let order = Order(id: "2131",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let shelf = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [order])
		
		XCTAssertTrue(shelf.isFull())

		let shelf2 = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [])
		
		XCTAssertFalse(shelf2.isFull())
		
		let order3 = Order(id: "35435",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order4 = Order(id: "5345435453",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order5 = Order(id: "534534534",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let shelf3 = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [order3,order4,order5])
		
		XCTAssertTrue(shelf3.isFull())
    }
	
	func testOrdersFromShelves() throws {
		
		let order1 = Order(id: "35435",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order2 = Order(id: "5345435453",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order3 = Order(id: "534534534",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let shelf1 = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [order1,order2,order3])
		
		let order4 = Order(id: "24342342",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order5 = Order(id: "423423423324234",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order6 = Order(id: "234232343223423",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let shelf2 = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [order4,order5,order6])
		
		let ordersFromShelves = Shelf.orders(fromShelves: [shelf1, shelf2])
		
		XCTAssertTrue(ordersFromShelves.count == 6)
		XCTAssertTrue(ordersFromShelves == [order1,order2,order3,order4,order5,order6])
	}
	
	func testShelfDecayModifierAutoSet() throws {
		
		let shelf1 = Shelf(name: "Any Shelf",
						  allowedTemperature: .any,
						  capacity: 1,
						  currentOrders: [])
		
		let shelf2 = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [])
		
		let shelf3 = Shelf(name: "Cold Shelf",
						  allowedTemperature: .cold,
						  capacity: 1,
						  currentOrders: [])
		
		let shelf4 = Shelf(name: "Frozen Shelf",
						  allowedTemperature: .frozen,
						  capacity: 1,
						  currentOrders: [])
		
		XCTAssertTrue(shelf1.shelfDecayModifier == 2)
		XCTAssertTrue(shelf2.shelfDecayModifier == 1)
		XCTAssertTrue(shelf3.shelfDecayModifier == 1)
		XCTAssertTrue(shelf4.shelfDecayModifier == 1)
	}
	
	func testShelfDescription() throws {
		let order4 = Order(id: "24342342",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order5 = Order(id: "423423423324234",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let order6 = Order(id: "234232343223423",
						  name: "Supino Pizza",
						  temp: .hot,
						  shelfLife: 10,
						  decayRate: 20)
		
		let shelf2 = Shelf(name: "Hot Shelf",
						  allowedTemperature: .hot,
						  capacity: 1,
						  currentOrders: [order4,order5,order6])
		
		let string = shelf2.shelfDescription(orderDecayInfo: [:])
		
		XCTAssertTrue(string == "\nHot Shelf\nCapacity: 1\nOrder Count: 3\nShelf Decay Modifier: 1\nOrders:Order(id: \"24342342\", name: \"Supino Pizza\", temp: GhostKitchenTests.ShelfTemperature.hot, shelfLife: 10, decayRate: 20.0), decay: 1.0 Order(id: \"423423423324234\", name: \"Supino Pizza\", temp: GhostKitchenTests.ShelfTemperature.hot, shelfLife: 10, decayRate: 20.0), decay: 1.0 Order(id: \"234232343223423\", name: \"Supino Pizza\", temp: GhostKitchenTests.ShelfTemperature.hot, shelfLife: 10, decayRate: 20.0), decay: 1.0 ")
	}
}
