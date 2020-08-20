//
//  OrderReciever.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: OrderCookingDelegate

protocol OrderCookingDelegate {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
     */
	func orderCooker(orderCooker: OrderCooking,
					 cookedOrders: [Order])
}

// MARK: OrderCooking

protocol OrderCooking {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
     */
	func cook(orders: [Order])

	/// Some Documentation
	var orderCookingDelegate: OrderCookingDelegate? { get set }
}

// MARK: OrderCooking

final class OrderCooker: OrderCooking  {
	
	var orderCookingDelegate: OrderCookingDelegate?
	
	func cook(orders: [Order]) {
		self.orderCookingDelegate?.orderCooker(orderCooker: self,
											   cookedOrders: orders)
	}
}
