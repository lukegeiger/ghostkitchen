//
//  CourierRouterTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation
import XCTest
@testable import GhostKitchens

class CourierRouterTests: XCTestCase {
	
	let commencePickupExpectation:XCTestExpectation = XCTestExpectation(description: "testCommencePickup")
	let commenceDropoffExpectation:XCTestExpectation = XCTestExpectation(description: "testCommenceDropoff")

	func testCommencePickup() throws {
		
		let router = CourierRouter()
		router.courierRoutingDelegate = self

		let hotOrder = Order(id: "1",
							 name: "Nemo Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let pickupTask = Task(type: .pickup, duration: 1, orderId: hotOrder.id)
		let dropoffTask = Task(type: .dropoff, duration: 0, orderId: hotOrder.id)

		let schedule = Schedule(scheduleId: UUID().uuidString,
								tasks: [pickupTask,dropoffTask])

		let courier = Courier(id: UUID().uuidString, schedule: schedule)
		
		router.commencePickupRoute(courier: courier)
		wait(for: [commencePickupExpectation], timeout: 7.0)
    }
	
	func testCommenceDropoff() throws {
		
		let router = CourierRouter()
		router.courierRoutingDelegate = self
		let hotOrder = Order(id: "1",
							 name: "Nemo Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let pickupTask = Task(type: .pickup, duration: 1, orderId: hotOrder.id)
		let dropoffTask = Task(type: .dropoff, duration: 0, orderId: hotOrder.id)


		let schedule = Schedule(scheduleId: UUID().uuidString,
								tasks: [pickupTask,dropoffTask])

		let courier = Courier(id: UUID().uuidString, schedule: schedule)
		
		router.commenceDropoffRoute(courier: courier)
		wait(for: [commenceDropoffExpectation], timeout: 7.0)
    }
	
	func testCourierRoutingArrivedPickupDelegate() throws {
		
		let router = CourierRouter()
		let spy = CourierRoutingDelegateSpy(expectation: self.commencePickupExpectation)
		router.courierRoutingDelegate = spy

		let hotOrder = Order(id: "1",
							 name: "Nemo Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)

		
		let pickupTask = Task(type: .pickup, duration: 1, orderId: hotOrder.id)
		let dropoffTask = Task(type: .dropoff, duration: 0, orderId: hotOrder.id)

		let schedule = Schedule(scheduleId: UUID().uuidString,
								tasks: [pickupTask,dropoffTask])

		let courier = Courier(id: UUID().uuidString, schedule: schedule)
		
		router.commencePickupRoute(courier: courier)
		wait(for: [commencePickupExpectation], timeout: 7.0)

		XCTAssertTrue(spy.testingCourier?.id == courier.id)
		XCTAssertTrue(spy.testingTask?.orderId == hotOrder.id)
		XCTAssertTrue(spy.testingOrderId == hotOrder.id)
	}
	
	func testCourierRoutingArrivedDropoffDelegate() throws {
		
		let router = CourierRouter()
		let spy = CourierRoutingDelegateSpy(expectation: self.commenceDropoffExpectation)
		router.courierRoutingDelegate = spy

		let hotOrder = Order(id: "1",
							 name: "Nemo Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let pickupTask = Task(type: .pickup,
							  duration: 0,
							  orderId: "1")
		
		let dropoffTask = Task(type: .dropoff,
							   duration: 0,
							   orderId: "1")

		let schedule = Schedule(scheduleId: UUID().uuidString,
								tasks: [pickupTask,dropoffTask])

		let courier = Courier(id: UUID().uuidString, schedule: schedule)
		
		router.commenceDropoffRoute(courier: courier)
		wait(for: [commenceDropoffExpectation], timeout: 7.0)

		XCTAssertTrue(spy.testingCourier?.id == courier.id)
		XCTAssertTrue(spy.testingTask?.orderId == hotOrder.id)
		XCTAssertTrue(spy.testingOrderId == hotOrder.id)
	}
}

extension CourierRouterTests: CourierRoutingDelegate {
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtPickup: Courier,
						   forTask: Task,
						   forOrderId: String) {
		
        commencePickupExpectation.fulfill()
	}
	
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtDropoff: Courier,
						   forTask: Task,
						   forOrderId: String) {
		
        commenceDropoffExpectation.fulfill()
	}
}

class CourierRoutingDelegateSpy:CourierRoutingDelegate {
	
	var testingCourier: Courier?
	var testingTask: Task?
	var testingOrderId: String?
	let expectation: XCTestExpectation
	
	init(expectation: XCTestExpectation) {
		self.expectation = expectation
	}

	func courierRouter(courierRouter: CourierRouting,
					   courierArrivedAtPickup: Courier,
					   forTask: Task,
					   forOrderId: String) {
		
		self.testingOrderId = forOrderId
		self.testingTask = forTask
		self.testingCourier = courierArrivedAtPickup
		self.expectation.fulfill()
	}
	
	func courierRouter(courierRouter: CourierRouting,
					   courierArrivedAtDropoff: Courier,
					   forTask: Task,
					   forOrderId: String) {
		
		self.testingOrderId = forOrderId
		self.testingTask = forTask
		self.testingCourier = courierArrivedAtDropoff
		self.expectation.fulfill()
	}
	
}
