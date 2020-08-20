//
//  OrderCookerTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class OrderCookerTests: XCTestCase {
		
	func testCookOrdersDelegate() {
		
		let orderCooker = OrderCooker()
		
		let cookedExpectation:XCTestExpectation = XCTestExpectation(description: "cookedExpectation")

		let spy = OrderCookingDelegateSpy(cookedExpectation: cookedExpectation)
		orderCooker.orderCookingDelegate = spy
		
		let hotOrder = Order(id: "1",
							 name: "Hot Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let coldOrder = Order(id: "2",
							  name: "Cold Drink",
							  temp: .cold,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		orderCooker.cook(orders: [hotOrder,coldOrder])
		XCTAssertTrue(spy.cookedOrders.count == 2)
		if let firstOrder = spy.cookedOrders.first {
			XCTAssertTrue(firstOrder.id == "1")
		}
		
		wait(for: [cookedExpectation], timeout: 1.0)
	}
}

class OrderCookingDelegateSpy: OrderCookingDelegate {
	
	var cookedOrders:[Order] = []
	var cookedExpectation:XCTestExpectation
	
	init(cookedExpectation:XCTestExpectation) {
		
		self.cookedExpectation = cookedExpectation
	}
	
	func orderCooker(orderCooker: OrderCooking,
					 cookedOrders: [Order]) {
		
		self.cookedOrders = cookedOrders
		self.cookedExpectation.fulfill()
	}
}
