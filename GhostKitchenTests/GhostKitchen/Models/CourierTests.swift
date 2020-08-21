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
	
	func testCreateCourierForOrder() throws {

		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		XCTAssertTrue(courier.schedule.routes.count == 1)
		
		let firstRoute = courier.schedule.routes.first
		XCTAssertNotNil(firstRoute)
		XCTAssertTrue(firstRoute?.order.id == "2")
    }
	
	func testPickupRouteIsRandomBetween2and6Seconds() throws {

		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		XCTAssertTrue(courier.schedule.routes.count == 1)
		
		let firstRoute = courier.schedule.routes.first
		
		if let firstRoute = firstRoute {
			XCTAssertTrue(firstRoute.timeToPickup >= 2 && firstRoute.timeToPickup <= 6 )
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
		
		XCTAssertTrue(courier.schedule.routes.count == 1)
		
		let firstRoute = courier.schedule.routes.first
		
		XCTAssertTrue(firstRoute?.timeToDropoff == 0)
    }
}
