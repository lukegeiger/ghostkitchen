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

	func testFlow() throws {
		
		let ghostKitchen = GhostKitchen.sampleKitchen()
		
		let receivedOrdersExpectation = XCTestExpectation(description: "")
		let cookedExpectation = XCTestExpectation(description: "cookedExpectation")
		let shelvedExpectation = XCTestExpectation(description: "shelvedExpectation")
		
		let courierPickupRemovalExpectation = XCTestExpectation(description: "courierPickupRemovalExpectation")
		courierPickupRemovalExpectation.expectedFulfillmentCount = 4;

		let overflowRemovalExpectation = XCTestExpectation(description: "overflowRemovalExpectation")
		let decayOrderExpectation = XCTestExpectation(description: "decayOrderExpectation")
		
		let routedExpectation = XCTestExpectation(description: "routedExpectation")
		routedExpectation.expectedFulfillmentCount = 4;
		
		let arrivedExpectation = XCTestExpectation(description: "arrivedExpectation")
		let deliveredExpectation = XCTestExpectation(description: "deliveredExpectation")

		let kitchenModuleDelegateSpy = KitchenModuleDelegateSpy(receivedOrdersExpectation: receivedOrdersExpectation,
														   cookedExpectation: cookedExpectation,
														   shelvedExpectation: shelvedExpectation,
														   courierPickupRemovalExpectation: courierPickupRemovalExpectation,
														   overflowRemovalExpectation: overflowRemovalExpectation,
														   decayOrderExpectation: decayOrderExpectation)
		
		let deliveryModuleDelegateSpy = DeliveryModuleDelegateSpy(routedExpectation: routedExpectation,
																 arrivedExpectation: arrivedExpectation,
																 deliveredExpectation: deliveredExpectation)
		
		
		ghostKitchen.deliveryModule.deliveryModuleDelegate = deliveryModuleDelegateSpy
		
		ghostKitchen.kitchenModule.kitchenModuleDelegate = kitchenModuleDelegateSpy

		let hotOrder = Order(id: "1",
								 name: "Nemo Burger",
								 temp: .hot,
								 shelfLife: 10,
								 decayRate: 0.0)
		
		let hotOrder2 = Order(id: "2",
								 name: "Supino Pizza",
								 temp: .hot,
								 shelfLife: 10,
								 decayRate: 0.0)
		
		let hotOrder3 = Order(id: "23",
								 name: "Slows BBQ",
								 temp: .hot,
								 shelfLife: 10,
								 decayRate: 0.0)
		
		
		let coldOrder = Order(id: "3",
								 name: "Frozen Pizza",
								 temp: .frozen,
								 shelfLife: 10,
								 decayRate: 0.0)
		
		ghostKitchen.kitchenModule.receive(orders: [hotOrder,
													hotOrder2,
													hotOrder3,
													coldOrder])
		
		ghostKitchen.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: [hotOrder,hotOrder2,hotOrder3,coldOrder])

		wait(for: [receivedOrdersExpectation,
				   cookedExpectation,
				   shelvedExpectation], timeout: 5.0, enforceOrder: true)
		
		let courier1 = Courier.createCourierForOrder(order: hotOrder)
		let courier2 = Courier.createCourierForOrder(order: hotOrder2)
		let courier3 = Courier.createCourierForOrder(order: hotOrder3)
		let courier4 = Courier.createCourierForOrder(order: coldOrder)

		ghostKitchen.deliveryModule.courierRouter.commencePickupRoute(courier: courier1)
		ghostKitchen.deliveryModule.courierRouter.commencePickupRoute(courier: courier2)
		ghostKitchen.deliveryModule.courierRouter.commencePickupRoute(courier: courier3)
		ghostKitchen.deliveryModule.courierRouter.commencePickupRoute(courier: courier4)

		ghostKitchen.kitchenModule.shelveOrderDistributor.remove(orderIds: [hotOrder.id], reason: .courierPickup)
		ghostKitchen.kitchenModule.shelveOrderDistributor.remove(orderIds: [hotOrder2.id], reason: .courierPickup)
		ghostKitchen.kitchenModule.shelveOrderDistributor.remove(orderIds: [hotOrder3.id], reason: .courierPickup)
		ghostKitchen.kitchenModule.shelveOrderDistributor.remove(orderIds: [coldOrder.id], reason: .courierPickup)

		ghostKitchen.deliveryModule.courierRouter.commenceDropoffRoute(courier: courier1)
		ghostKitchen.deliveryModule.courierRouter.commenceDropoffRoute(courier: courier2)
		ghostKitchen.deliveryModule.courierRouter.commenceDropoffRoute(courier: courier3)
		ghostKitchen.deliveryModule.courierRouter.commenceDropoffRoute(courier: courier4)
				
		wait(for: [routedExpectation,
				   arrivedExpectation,
				   courierPickupRemovalExpectation,
				   deliveredExpectation], timeout: 7.0)
	}
	
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
