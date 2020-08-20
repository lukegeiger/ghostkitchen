//
//  GhostKitchenTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class GhostKitchenTests: XCTestCase {

	func testGhostKitchen() {
		
		let shelf1 = Shelf(name: "Hot Shelf",
						   allowedTemperature: .hot,
						   capacity: 10,
						   currentOrders: [])

		let shelf2 = Shelf(name: "Cold Shelf",
						   allowedTemperature: .cold,
						   capacity: 10,
						   currentOrders: [])

		let shelf3 = Shelf(name: "Frozen Shelf",
						   allowedTemperature: .frozen,
						   capacity: 10,
						   currentOrders: [])

		let shelf4 = Shelf(name: "Overflow Shelf",
						   allowedTemperature: .any,
						   capacity: 15,
						   currentOrders: [])
				
		let courierDispatcher = CourierDispatcher()
		let routeSimulator = CourierRouter()
		
		let deliveryModule = DeliveryModule(courierDispatcher: courierDispatcher,
											courierRouter: routeSimulator)
		
		let orderCooker = OrderCooker()

		let decay = OrderDecayMonitor()
		let shelveOrderDistributor = ShelveOrderDistributor(shelves: [shelf1,shelf2,shelf3,shelf4],
															decayMonitor: decay)

		let kitchenModule = KitchenModule(orderCooker: orderCooker,
										  shelveOrderDistributor: shelveOrderDistributor)
		
		let ghostKitchen = GhostKitchen(kitchenModule: kitchenModule,
										deliveryModule: deliveryModule)
			
		XCTAssertNotNil(ghostKitchen.kitchenModule.kitchenModuleDelegate)
		XCTAssertNotNil(ghostKitchen.deliveryModule.deliveryModuleDelegate)
	}
}
