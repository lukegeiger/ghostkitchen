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
     A delegate callback that lets a consumer know when a courier was routed

     - Parameters:
        - courierDispatcher: The dispatcher that performed the action
        - routedCourier: The courier who got routed
		- order: The courier who got routed
     */
	func courierDispatcher(courierDispatcher: CourierDispatching,
					       routedCourier: Courier,
						   forOrder: Order)
}

// MARK: CourierDispatching

protocol CourierDispatching {
	
    /**
     Calling this will dispatch couriers to the orders and begin their pickup and dropoff journey

     - Parameters:
        - forOrders: The orders that need to be picked up and delivered
     */
	func dispatchCouriers(forOrders: [Order])

	var courierDispatchDelegate: CourierDispatchDelegate? { get set }
}

// MARK: CourierDispatcher

final class CourierDispatcher: CourierDispatching {
	
	var courierDispatchDelegate: CourierDispatchDelegate?
	
	func dispatchCouriers(forOrders: [Order]) {
		forOrders.forEach { (order) in
			self.courierDispatchDelegate?.courierDispatcher(courierDispatcher: self,
															routedCourier: Courier.createCourierForOrder(order: order),
															forOrder: order)
		}
	}
}

