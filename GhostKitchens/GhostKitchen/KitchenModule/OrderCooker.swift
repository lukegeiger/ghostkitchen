//
//  OrderReciever.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: OrderCookingDelegate

protocol OrderCookingDelegate: class {
	
    /**
		A delegate callback to notify when the order cooker finished cooking.

     - Parameters:
        - orderCooker: An instance of the order cooker that cooked the orders
        - orderCooker: The cooked orders.
     */
	func orderCooker(orderCooker: OrderCooking,
					 cookedOrders: [Order])
}

// MARK: OrderCooking

protocol OrderCooking: class {
	
    /**
		Pass in orders that need to be coked.

     - Parameters:
        - orders: Uncooked orders.
     */
	func cook(orders: [Order])

	var orderCookingDelegate: OrderCookingDelegate? { get set }
}

// MARK: OrderCooking

final class OrderCooker: OrderCooking  {
	
	weak var orderCookingDelegate: OrderCookingDelegate?
	
	func cook(orders: [Order]) {
		self.orderCookingDelegate?.orderCooker(orderCooker: self,
											   cookedOrders: orders)
	}
}
