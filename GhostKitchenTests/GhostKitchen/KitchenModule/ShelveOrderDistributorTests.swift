//
//  ShelveOrderDistributorTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class ShelveOrderDistributorTests: XCTestCase {
		
	func testHeatAssignment() throws {
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [])
		
		let coldShelf = Shelf(name: "Cold Shelf",
							  allowedTemperature: .cold,
							  capacity: 1,
							  currentOrders: [])
		
		let frozenShelf = Shelf(name: "Frozen Shelf",
								allowedTemperature: .frozen,
								capacity: 1,
								currentOrders: [])
		
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
		
		let frozenOrder = Order(id: "3",
								name: "Frozen Pizza",
								temp: .frozen,
								shelfLife: 10,
								decayRate: 0.0)
		
		let decayer = OrderDecayMonitor()
		let shelfOrderDistributor = ShelveOrderDistributor(shelves: [hotShelf,coldShelf,frozenShelf], decayMonitor: decayer)
		shelfOrderDistributor.shelve(orders: [hotOrder,coldOrder,frozenOrder])
		
		let assignedShelf1 = shelfOrderDistributor.shelf(forOrder: hotOrder)
		XCTAssertTrue(assignedShelf1?.currentOrders.count == 1)
		XCTAssertTrue(assignedShelf1?.name == "Hot Shelf")
		
		let assignedShelf2 = shelfOrderDistributor.shelf(forOrder: coldOrder)
		XCTAssertTrue(assignedShelf2?.currentOrders.count == 1)
		XCTAssertTrue(assignedShelf2?.name == "Cold Shelf")
		
		let assignedShelf3 = shelfOrderDistributor.shelf(forOrder: frozenOrder)
		XCTAssertTrue(assignedShelf3?.currentOrders.count == 1)
		XCTAssertTrue(assignedShelf3?.name == "Frozen Shelf")
	}
	
	func testOverflow() throws {
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [])
		
		let overflowShelf = Shelf(name: "Overflow Shelf",
								  allowedTemperature: .any,
								  capacity: 1,
								  currentOrders: [])
		
		let hotOrder1 = Order(id: "1",
							  name: "Nemo Burger",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let hotOrder2 = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		let decayer = OrderDecayMonitor()
		let shelfOrderDistributor = ShelveOrderDistributor(shelves: [hotShelf,overflowShelf],decayMonitor: decayer)
		shelfOrderDistributor.shelve(orders: [hotOrder1,hotOrder2])
		
		let updatedHotShelf = shelfOrderDistributor.shelf(forOrder: hotOrder1)
		XCTAssertTrue(updatedHotShelf?.currentOrders.count == 1)
		XCTAssertTrue(updatedHotShelf?.name == "Hot Shelf")
		
		let nemoBurgerOrder = updatedHotShelf?.currentOrders.first
		XCTAssertTrue(nemoBurgerOrder?.id == "1")
		
		let updatedOverflowShelf = shelfOrderDistributor.shelf(forOrder: hotOrder2)
		XCTAssertTrue(updatedOverflowShelf?.currentOrders.count == 1)
		XCTAssertTrue(updatedOverflowShelf?.name == "Overflow Shelf")
		
		let supinoPizzaOrder = updatedOverflowShelf?.currentOrders.first
		XCTAssertTrue(supinoPizzaOrder?.id == "2")
	}
	
	func testCapacityNoOverflow() throws {
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [])
		
		let hotOrder1 = Order(id: "1",
							  name: "Nemo Burger",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let hotOrder2 = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let decayer = OrderDecayMonitor()
		let shelfOrderDistributor = ShelveOrderDistributor(shelves: [hotShelf],decayMonitor: decayer)
		shelfOrderDistributor.shelve(orders: [hotOrder1,hotOrder2])
		
		let updatedHotShelf = shelfOrderDistributor.shelf(forOrder: hotOrder1)
		XCTAssertTrue(updatedHotShelf?.currentOrders.count == 1)
		XCTAssertTrue(updatedHotShelf?.name == "Hot Shelf")
		
		let nemoBurgerOrder = updatedHotShelf?.currentOrders.first
		XCTAssertTrue(nemoBurgerOrder?.id == "1")
	}
	
	func testRemove() throws {
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 3,
							 currentOrders: [])
		
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
		
		let hotOrder3 = Order(id: "3",
							  name: "Batch BBQ",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let decayer = OrderDecayMonitor()
		let shelfOrderDistributor = ShelveOrderDistributor(shelves: [hotShelf],decayMonitor: decayer)
		shelfOrderDistributor.shelve(orders: [hotOrder,hotOrder2,hotOrder3])
		XCTAssertTrue(hotShelf.currentOrders.count == 3)
		shelfOrderDistributor.remove(orders: [hotOrder,hotOrder2], reason: .courierPickup)
		XCTAssertTrue(hotShelf.currentOrders.count == 1)
	}
	
	func testAutoRemoveOverflow() throws {
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 2,
							 currentOrders: [])
		
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
		
		let hotOrder3 = Order(id: "3",
							  name: "Batch BBQ",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let decayer = OrderDecayMonitor()
		let shelfOrderDistributor = ShelveOrderDistributor(shelves: [hotShelf],decayMonitor: decayer)
		shelfOrderDistributor.shelve(orders: [hotOrder,hotOrder2])
		XCTAssertTrue(hotShelf.currentOrders.count == 2)
		shelfOrderDistributor.shelve(orders: [hotOrder3])
		XCTAssertTrue(hotShelf.currentOrders.count == 2)
	}
	
	func testSimpleShelve() throws {
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 3,
							 currentOrders: [])
		
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
				
		let decayer = OrderDecayMonitor()
		let shelfOrderDistributor = ShelveOrderDistributor(shelves: [hotShelf],decayMonitor: decayer)
		XCTAssertTrue(hotShelf.currentOrders.count == 0)
		shelfOrderDistributor.shelve(orders: [hotOrder,hotOrder2])
		XCTAssertTrue(hotShelf.currentOrders.count == 2)
	}
	
	// MARK: ShelveOrderDistributorDelegateSpy Testing

	func testShelveOrderDistributorShelvedOrderDelegate() throws {
		
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [])
		
		let hotOrder = Order(id: "1",
							 name: "Nemo Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let decayer = OrderDecayMonitor()
		let shelf = ShelveOrderDistributor(shelves: [hotShelf],decayMonitor: decayer)
		
		let shelvedExpectation = XCTestExpectation(description: "shelvedExpectation")
		
		let spy = ShelveOrderDistributorDelegateSpy(testingOrder: hotOrder,
													testingShelf: hotShelf,
													shelvedExpectation: shelvedExpectation)
		
		shelf.shelveOrderDistributorDelegate = spy
		
		shelf.shelve(orders: [hotOrder])
		
		XCTAssertTrue(spy.testingShelf?.name == "Hot Shelf")
		XCTAssertTrue(spy.testingOrder?.id == "1")
		wait(for: [shelvedExpectation], timeout: 1.0)
	}
	
	func testShelveOrderDistributorShelvedRemovedDelegate() throws {
		let hotShelf = Shelf(name: "Hot Shelf",
							 allowedTemperature: .hot,
							 capacity: 1,
							 currentOrders: [])
		
		let hotOrder = Order(id: "1",
							 name: "Nemo Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let decayer = OrderDecayMonitor()
		let shelf = ShelveOrderDistributor(shelves: [hotShelf], decayMonitor: decayer)
		
		let removedExpectation = XCTestExpectation(description: "removedExpectation")

		let spy = ShelveOrderDistributorDelegateSpy(testingOrder: hotOrder,
													testingShelf: hotShelf,
													shelvedExpectation: removedExpectation)
		
		shelf.shelveOrderDistributorDelegate = spy
		shelf.shelve(orders: [hotOrder])
		shelf.remove(orders: [hotOrder], reason: .courierPickup)
		
		XCTAssertTrue(spy.testingShelf?.name == "Hot Shelf")
		XCTAssertTrue(spy.testingOrder?.id == "1")
		wait(for: [removedExpectation], timeout: 1.0)
	}
}

class ShelveOrderDistributorDelegateSpy: ShelveOrderDistributorDelegate {

	var testingOrder: Order?
	var testingShelf: Shelf?
	var shelvedExpectation: XCTestExpectation?
	var removedForPickupExpectation: XCTestExpectation?
	var removedForOverflowExpectation: XCTestExpectation?
	var removedForDecayExpectaion: XCTestExpectation?

	init(testingOrder: Order? = nil,
		 testingShelf: Shelf? = nil,
		 shelvedExpectation: XCTestExpectation? = nil,
		 removedForPickupExpectation: XCTestExpectation? = nil,
		 removedForOverflowExpectation: XCTestExpectation? = nil,
		 removedForDecayExpectaion: XCTestExpectation? = nil) {
		self.testingOrder = testingOrder
		self.testingShelf = testingShelf
		self.shelvedExpectation = shelvedExpectation
		self.removedForPickupExpectation = removedForPickupExpectation
		self.removedForOverflowExpectation = removedForOverflowExpectation
		self.removedForDecayExpectaion = removedForDecayExpectaion
	}
	
	func shelveOrderDistributor(shelveOrderDistributor:ShelveOrderDistributor,
								shelvedOrder:Order,
								onShelf:Shelf) {
		self.testingOrder = shelvedOrder
		self.testingShelf = onShelf
		
		if let shelvedExpectation = shelvedExpectation {
			shelvedExpectation.fulfill()
		}
	}
	
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								removed: Order,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason) {
		self.testingOrder = removed
		self.testingShelf = fromShelf
		
		switch reason {

		case .courierPickup:
			if let removedForPickupExpectation = removedForPickupExpectation {
				removedForPickupExpectation.fulfill()
			}
			break
		case .overflow:
			if let removedForOverflowExpectation = removedForOverflowExpectation {
				removedForOverflowExpectation.fulfill()
			}
			break
		case .decay:
			if let removedForDecayExpectaion = removedForDecayExpectaion {
				removedForDecayExpectaion.fulfill()
			}
			break
		}
	}
}

