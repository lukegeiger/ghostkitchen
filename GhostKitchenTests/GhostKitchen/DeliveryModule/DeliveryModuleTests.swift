//
//  DeliveryModuleTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class DeliveryModuleTests: XCTestCase {
	
	func testDeliveryFlow() throws {
		
		let courierDispatcher = CourierDispatcher()
		let router = CourierRouter()
		
		let module = DeliveryModule(courierDispatcher: courierDispatcher,
									courierRouter: router)
		
		let routedExpectation = XCTestExpectation(description: "routedExpectation")
		let arrivedExpectation = XCTestExpectation(description: "arrivedExpectation")
		let deliveredExpectation = XCTestExpectation(description: "deliveredExpectation")

		let spy = DeliveryModuleDelegateSpy(routedExpectation: routedExpectation,
											arrivedExpectation: arrivedExpectation,
											deliveredExpectation: deliveredExpectation)
		
		module.deliveryModuleDelegate = spy
		
		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		courierDispatcher.dispatchCouriers(forOrders: [hotOrder])
		router.commencePickupRoute(courier: courier)
		
		wait(for: [routedExpectation,arrivedExpectation],
			 timeout: 7.0,
				 enforceOrder: true)
		
		router.commenceDropoffRoute(courier: courier)
		
		wait(for: [deliveredExpectation], timeout: 7.0)
	}
	
	func testDeliveryModuleDispatchCouriers() {
		
		let courierDispatcher = CourierDispatcher()
		let router = CourierRouter()
		
		let module = DeliveryModule(courierDispatcher: courierDispatcher,
									courierRouter: router)
		
		let routedExpectation = XCTestExpectation(description: "routedExpectation")
		
		let spy = DeliveryModuleDelegateSpy(routedExpectation:routedExpectation)
		
		module.deliveryModuleDelegate = spy

		let hotOrder = Order(id: "1",
							 name: "Hot Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		module.courierDispatcher.dispatchCouriers(forOrders: [hotOrder])
		
		XCTAssertTrue(spy.testingCourier?.schedule.routes.count == 1)
		
		if let firstRoute = spy.testingCourier?.schedule.routes.first {
			XCTAssertTrue(firstRoute.orderId == "1")
		}
		
		wait(for: [routedExpectation], timeout: 7.0)
	}
	
	func testDeliveryModuleCommencePickupRoute() throws {
		
		let courierDispatcher = CourierDispatcher()
		let router = CourierRouter()
		
		let module = DeliveryModule(courierDispatcher: courierDispatcher,
									courierRouter: router)
		
		let arrivedExpectation = XCTestExpectation(description: "arrivedExpectation")
		
		let spy = DeliveryModuleDelegateSpy(arrivedExpectation:arrivedExpectation)
		
		module.deliveryModuleDelegate = spy
		
		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		router.commencePickupRoute(courier: courier)
		
		wait(for: [arrivedExpectation], timeout: 7.0)
		
		XCTAssertTrue(spy.testingOrderId == "2")
		XCTAssertTrue(spy.testingCourier?.id == courier.id)
	}
	
	func testDeliveryModuleCommenceDropoffRoute() throws {
		let courierDispatcher = CourierDispatcher()
		let router = CourierRouter()
		
		let module = DeliveryModule(courierDispatcher: courierDispatcher,
									courierRouter: router)
		
		let deliveredExpectation = XCTestExpectation(description: "deliveredExpectation")
		
		let spy = DeliveryModuleDelegateSpy(deliveredExpectation:deliveredExpectation)

		module.deliveryModuleDelegate = spy
		
		let hotOrder = Order(id: "2",
							  name: "Supino Pizza",
							  temp: .hot,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		
		let courier = Courier.createCourierForOrder(order: hotOrder)
		
		router.commenceDropoffRoute(courier: courier)
		
		wait(for: [deliveredExpectation], timeout: 7.0)
		
		XCTAssertTrue(spy.testingOrderId == "2")
		XCTAssertTrue(spy.testingCourier?.id == courier.id)
	}
}

class DeliveryModuleDelegateSpy:DeliveryModuleDelegate {
	
	var testingOrderId: String?
	var testingCourier: Courier?
	
	var routedExpectation: XCTestExpectation?
	var arrivedExpectation: XCTestExpectation?
	var deliveredExpectation: XCTestExpectation?
	
	init(routedExpectation: XCTestExpectation? = nil,
		 arrivedExpectation: XCTestExpectation? = nil,
		 deliveredExpectation: XCTestExpectation? = nil) {
		self.routedExpectation = routedExpectation
		self.arrivedExpectation = arrivedExpectation
		self.deliveredExpectation = deliveredExpectation
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrderId: String,
						onRoute: String) {
		self.testingOrderId = arrivedForOrderId
		self.testingCourier = courier
		if let arrivedExpectation = self.arrivedExpectation {
			arrivedExpectation.fulfill()
		}
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier,
						forOrder: Order) {
		self.testingCourier = routed
		if let routedExpectation = self.routedExpectation {
			routedExpectation.fulfill()
		}
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrderId: String) {
		self.testingOrderId = deliveredOrderId
		self.testingCourier = courier

		if let deliveredExpectation = self.deliveredExpectation {
			deliveredExpectation.fulfill()
		}
	}

}


