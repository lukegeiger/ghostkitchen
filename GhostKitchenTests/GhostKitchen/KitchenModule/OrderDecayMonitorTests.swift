//
//  OrderDecayMonitorTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class OrderDecayMonitorTests: XCTestCase {
		
	var shelves:[Shelf] = []
	
    override func setUpWithError() throws {
		
		self.shelves = self.testingShelves()
    }

    override func tearDownWithError() throws {
		
		self.shelves.removeAll()
   }
	
	func testDataSourceShelves() throws {
		
		let orderDecay = OrderDecayMonitor()
		let datasourceSpy = OrderDecayMonitorDataSourceSpy()
		orderDecay.orderDecayMonitorDataSource = datasourceSpy
		XCTAssertTrue(datasourceSpy.monitoringShelves().count == self.shelves.count)
	}
	
	func testDecay() throws {
		
		let orderDecay = OrderDecayMonitor()
		let decayExpectation = XCTestExpectation(description: "decayExpectation")
		let delegateSpy = OrderDecayMonitorDelegateSpy(decayExpectation: decayExpectation)
		let datasourceSpy = OrderDecayMonitorDataSourceSpy()
		
		orderDecay.orderDecayMonitorDelegate = delegateSpy
		orderDecay.orderDecayMonitorDataSource = datasourceSpy
		
		orderDecay.beginMonitoring()
				
		wait(for: [decayExpectation], timeout: 5.0)
	}

	func testingShelves() -> [Shelf] {
		
		let hotOrder = Order(id: "1",
							 name: "Hot Burger",
							 temp: .hot,
							 shelfLife: 1,
							 decayRate: 0.9)
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [hotOrder])
		return [hotShelf]
	}
}

struct OrderDecayMonitorDelegateSpy: OrderDecayMonitorDelegate {
	
	var decayExpectation:XCTestExpectation?
	
	func orderDecayMonitor(monitor: OrderDecayMonitor,
						   detectedDecayedOrder: Order) {
	
		if let decayExpectation = decayExpectation {
			decayExpectation.fulfill()
		}
	}
}

class OrderDecayMonitorDataSourceSpy: OrderDecayMonitorDataSource {
	
	func monitoringShelves() -> [Shelf] {
		
		let hotOrder = Order(id: "1",
							 name: "Hot Burger",
							 temp: .hot,
							 shelfLife: 1,
							 decayRate: 0.2)
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [hotOrder])
		return [hotShelf]
	}
}

