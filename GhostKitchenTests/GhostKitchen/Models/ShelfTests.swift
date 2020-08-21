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
}
