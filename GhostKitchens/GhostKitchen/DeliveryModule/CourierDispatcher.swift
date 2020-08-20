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
	
	func courierDispatcher(courierDispatcher: CourierDispatching,
					       routedCourier: Courier)
}

// MARK: CourierDispatching

protocol CourierDispatching {
	
	func dispatchCouriers(forOrders: [Order])

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

