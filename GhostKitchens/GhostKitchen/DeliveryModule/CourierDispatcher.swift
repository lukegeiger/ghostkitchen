//
//  CourierDispatcher.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: CourierDispatchDelegate

protocol CourierDispatchDelegate {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
     */
	func courierDispatcher(courierDispatcher: CourierDispatching,
					       routedCourier: Courier)
}

// MARK: CourierDispatching

protocol CourierDispatching {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
     */
	func dispatchCouriers(forOrders: [Order])

	/// Some Documentation
	var courierDispatchDelegate: CourierDispatchDelegate? { get set }
}

// MARK: CourierDispatcher

final class CourierDispatcher: CourierDispatching {
	
	var courierDispatchDelegate: CourierDispatchDelegate?
	
	func dispatchCouriers(forOrders: [Order]) {
		forOrders.forEach { (order) in
			self.courierDispatchDelegate?.courierDispatcher(courierDispatcher: self,
															routedCourier: Courier.createCourierForOrder(order: order))
		}
	}
}

