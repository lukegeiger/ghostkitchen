//
//  CourierDispatcherTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class CourierDispatcherTests: XCTestCase {
		
	func testDispatchCouriers() {
		
		let dispatcher = CourierDispatcher()
		
		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		let dispatchCouriersExpectation:XCTestExpectation = XCTestExpectation(description: "dispatchCouriersExpectation")

		let spy = CourierDispatchDelegateSpy(testingCourier: courier,
											 expectation: dispatchCouriersExpectation)
		dispatcher.courierDispatchDelegate = spy
		
		dispatcher.dispatchCouriers(forOrders: [hotOrder])
				
		XCTAssertTrue(spy.testingCourier.schedule.tasks.count == 2)
		
		if let firstRoute = spy.testingCourier.schedule.tasks.first {
			XCTAssertTrue(firstRoute.orderId == "2")
		}
		
		wait(for: [dispatchCouriersExpectation], timeout: 7.0)
	}
}

class CourierDispatchDelegateSpy: CourierDispatchDelegate {

	var testingCourier: Courier
	var expectation: XCTestExpectation
	
	init(testingCourier: Courier,
		 expectation: XCTestExpectation) {
		
		self.testingCourier = testingCourier
		self.expectation = expectation
	}
	
	func courierDispatcher(courierDispatcher: CourierDispatching,
						   routedCourier: Courier,
						   forOrder: Order) {
		self.testingCourier = routedCourier
		self.expectation.fulfill()
	}
}
