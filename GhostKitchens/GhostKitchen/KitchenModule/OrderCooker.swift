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
	
	func orderCooker(orderCooker: OrderCooking,
					 cookedOrders: [Order])
}

// MARK: OrderCooking

protocol OrderCooking {
	
	func cook(orders: [Order])
	var orderCookingDelegate: OrderCookingDelegate? { get set }
}

// MARK: OrderCooking

class OrderCooker: OrderCooking  {
	
	var orderCookingDelegate: OrderCookingDelegate?
	
	func cook(orders: [Order]) {
		self.orderCookingDelegate?.orderCooker(orderCooker: self,
											   cookedOrders: orders)
	}
}
