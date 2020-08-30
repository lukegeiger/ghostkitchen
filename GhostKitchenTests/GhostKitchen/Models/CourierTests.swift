//
//  CourierTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation


import XCTest
@testable import GhostKitchens

class CourierTests: XCTestCase {
	
	
	func testEquality() throws {
		
		let order1 = Order(id: "1",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		
		let order2 = Order(id: "2",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		
		let courierOne = Courier.createCourierForOrder(order: order1)

		let courierTwo = Courier.createCourierForOrder(order: order2)

		XCTAssertTrue(courierOne != courierTwo)
    }
	
	func testCreateCourierForOrder() throws {

		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		XCTAssertTrue(courier.schedule.tasks.count == 2)
		
		XCTAssertTrue(courier.schedule.tasks[0].orderId == "2")
		XCTAssertTrue(courier.schedule.tasks[1].orderId == "2")

		let firstRoute = courier.schedule.tasks.first
		XCTAssertNotNil(firstRoute)
		XCTAssertTrue(firstRoute?.orderId == "2")
    }
	
	func testPickupRouteIsRandomBetween2and6Seconds() throws {

		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		XCTAssertTrue(courier.schedule.tasks.count == 2)
		
		let firstRoute = courier.schedule.tasks.first
		
		if let firstRoute = firstRoute {
			XCTAssertTrue(firstRoute.duration >= 2 && firstRoute.duration <= 6 )
		} else {
			XCTAssertTrue(false)
		}
    }
	
	func testDropoffRouteIsInstant() throws {

		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		XCTAssertTrue(courier.schedule.tasks.count == 2)

		let firstRoute = courier.schedule.tasks.last
		
		XCTAssertTrue(firstRoute?.duration == 0)
    }
}
