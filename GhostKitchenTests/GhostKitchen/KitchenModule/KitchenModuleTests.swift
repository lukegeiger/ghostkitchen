//
//  KitchenModuleTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class KitchenModuleTests: XCTestCase {

	func testKitchenFlow() throws {
		
		let orderCooker = OrderCooker()
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [])
		
		let coldShelf = Shelf(name: "Cold Shelf",
							 allowedTemperature: .cold,
							 capacity: 1,
							 currentOrders: [])
		
		let overflowShelf = Shelf(name: "Overflow Shelf",
							 allowedTemperature: .any,
							 capacity: 1,
							 currentOrders: [])
		
		let decay = OrderDecayMonitor()
		let shelveDistributor = ShelveOrderDistributor(shelves: [hotShelf, coldShelf,overflowShelf], decayMonitor: decay)
		
		let kitchenModule = KitchenModule(orderCooker: orderCooker,
										  shelveOrderDistributor: shelveDistributor)
		
		
		let receivedOrdersExpectation = XCTestExpectation(description: "receivedOrdersExpectation")
		let cookedExpectation = XCTestExpectation(description: "cookedExpectation")
		let shelvedExpectation = XCTestExpectation(description: "shelvedExpectation")
		shelvedExpectation.expectedFulfillmentCount = 4
		
		let overflowRemovalExpectation = XCTestExpectation(description: "overflowRemovalExpectation")
		
		let spy = KitchenModuleDelegateSpy(receivedOrdersExpectation: receivedOrdersExpectation,
										   cookedExpectation: cookedExpectation,
										   shelvedExpectation: shelvedExpectation,
										   overflowRemovalExpectation: overflowRemovalExpectation)
		
		kitchenModule.kitchenModuleDelegate = spy
		
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
		
		
		kitchenModule.receive(orders: [hotOrder,hotOrder2,hotOrder3,coldOrder])
		
		wait(for: [receivedOrdersExpectation,cookedExpectation,shelvedExpectation,overflowRemovalExpectation], timeout: 5.0)
	}
	
	func testKitchenFlowRemove() throws {
		
		let orderCooker = OrderCooker()
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 3,
							 currentOrders: [])
	
		let overflowShelf = Shelf(name: "Overflow Shelf",
							 allowedTemperature: .any,
							 capacity: 1,
							 currentOrders: [])
		
		let decay = OrderDecayMonitor()

		let shelveDistributor = ShelveOrderDistributor(shelves: [hotShelf,overflowShelf], decayMonitor: decay)
		
		let kitchenModule = KitchenModule(orderCooker: orderCooker,
										  shelveOrderDistributor: shelveDistributor)
		
		let courierPickupRemovalExpectation = XCTestExpectation(description: "courierPickupRemovalExpectation")
		
		let spy = KitchenModuleDelegateSpy(courierPickupRemovalExpectation:courierPickupRemovalExpectation)
		
		kitchenModule.kitchenModuleDelegate = spy
		
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
		
		kitchenModule.receive(orders: [hotOrder,hotOrder2,hotOrder3,coldOrder])
		kitchenModule.shelveOrderDistributor.remove(orderIds: [hotOrder.id,hotOrder2.id],reason: .courierPickup)
		
		wait(for: [courierPickupRemovalExpectation], timeout: 7.0)
	}
}

class KitchenModuleDelegateSpy: KitchenModuleDelegate {
	
	var receivedOrdersExpectation: XCTestExpectation? = nil
	var cookedExpectation: XCTestExpectation? = nil
	var shelvedExpectation: XCTestExpectation? = nil
	var courierPickupRemovalExpectation: XCTestExpectation? = nil
	var overflowRemovalExpectation: XCTestExpectation? = nil
	var decayOrderExpectation: XCTestExpectation? = nil

	init (receivedOrdersExpectation: XCTestExpectation? = nil,
		   cookedExpectation: XCTestExpectation? = nil,
		   shelvedExpectation: XCTestExpectation? = nil,
		   courierPickupRemovalExpectation: XCTestExpectation? = nil,
		   overflowRemovalExpectation: XCTestExpectation? = nil ,
		   decayOrderExpectation: XCTestExpectation? = nil) {
		self.receivedOrdersExpectation = receivedOrdersExpectation
		self.cookedExpectation = cookedExpectation
		self.shelvedExpectation = shelvedExpectation
		self.courierPickupRemovalExpectation = courierPickupRemovalExpectation
		self.overflowRemovalExpectation = overflowRemovalExpectation
		self.decayOrderExpectation = decayOrderExpectation
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   removedOrderId: String,
					   fromShelf: Shelf,
					   reason: ShelveOrderDistributorRemovalReason) {
		switch reason {
		case .courierPickup:
			if let courierPickupRemovalExpectation = courierPickupRemovalExpectation {
				courierPickupRemovalExpectation.fulfill()
			}
			break
		case .overflow:
			if let overflowRemovalExpectation = overflowRemovalExpectation {
				overflowRemovalExpectation.fulfill()
			}
			break
		case .decay:
			if let decayOrderExpectation = decayOrderExpectation {
				decayOrderExpectation.fulfill()
			}
			break
		}
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   receivedOrders: [Order]) {
		if let receivedOrdersExpectation = receivedOrdersExpectation {
			receivedOrdersExpectation.fulfill()
		}
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   cooked: [Order]) {
		if let cookedExpectation = cookedExpectation {
			cookedExpectation.fulfill()
		}
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
								shelvedOrder: Order,
								onShelf: Shelf) {
		if let shelvedExpectation = shelvedExpectation {
			shelvedExpectation.fulfill()
		}
	}
}
