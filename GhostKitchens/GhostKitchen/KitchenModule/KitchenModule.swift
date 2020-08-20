//
//  KitchenModule.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: KitchenModuleDelegate

protocol KitchenModuleDelegate {
	
    /**
		A delegate call back that notifies when the kitchen recieved orders.

     - Parameters:
        - kitchenModule: The instance of a kitchen modile that received the orders.
        - receivedOrders: The received orders.
     */
	func kitchenModule(kitchenModule: KitchenModule,
				 receivedOrders: [Order])
	
    /**
	 A delegate call back that notifies when the kitchen cooked orders.

     - Parameters:
        - kitchenModule: The instance of a kitchen modile that cooked the orders.
        - cooked: The cooked orders.
     */
	func kitchenModule(kitchenModule: KitchenModule,
						cooked: [Order])
	
    /**
	 A delegate call back that notifies when the kitchen shelved an order.

     - Parameters:
        - kitchenModule: The instance of a kitchen modile that shelved the orders.
        - shelvedOrder: The shelved order.
        - onShelf: The shelf the order was placed on.
     */
	func kitchenModule(kitchenModule: KitchenModule,
								shelvedOrder: Order,
								onShelf: Shelf)
	
    /**
	A delegate call back that notifies when the kitchen removed an order for a reason.

     - Parameters:
        - kitchenModule: The instance of a kitchen modile that received the orders
        - removed: The order that was removed
        - fromShelf: The shelf the order was removed from
        - reason: The reason why the kitchen removed an order from a shelf
     */
	func kitchenModule(kitchenModule: KitchenModule,
								removed: Order,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason)
}

// MARK: KitchenModule

final class KitchenModule {
	
	var orderCooker: OrderCooking
	var shelveOrderDistributor: ShelveOrderDistributing
	var kitchenModuleDelegate: KitchenModuleDelegate?

    /**
     Initializes a new KitchenModule that will be responsible for cooking, and manging the health of an order.

     - Parameters:
        - orderCooker: The order cooker is responsible for managing cooking of an order
        - shelveOrderDistributor: the shelve order distributor is responsible for shelving an order and tracking the status of its health.

     - Returns: A kitchen ready to make some awesome food!
     */
	init(orderCooker: OrderCooking,
		 shelveOrderDistributor: ShelveOrderDistributing) {
		
		self.orderCooker = orderCooker
		self.shelveOrderDistributor = shelveOrderDistributor
		self.shelveOrderDistributor.shelveOrderDistributorDelegate = self
		self.orderCooker.orderCookingDelegate = self
	}
}

// MARK: Public API

extension KitchenModule {
	
	func receive(orders: [Order]) {
		self.kitchenModuleDelegate?.kitchenModule(kitchenModule: self,
												 receivedOrders: orders)
		self.orderCooker.cook(orders: orders)
	}
}

// MARK: OrderCookingDelegate

extension KitchenModule: OrderCookingDelegate {
	
	func orderCooker(orderCooker: OrderCooking,
					 cookedOrders: [Order]) {
		
		self.kitchenModuleDelegate?.kitchenModule(kitchenModule: self,
												  cooked: cookedOrders)
		self.shelveOrderDistributor.shelve(orders: cookedOrders)
	}
}

// MARK: ShelveOrderDistributorDelegate

extension KitchenModule: ShelveOrderDistributorDelegate {
	
	
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								shelvedOrder: Order,
								onShelf: Shelf) {
		
		self.kitchenModuleDelegate?.kitchenModule(kitchenModule: self,
												  shelvedOrder: shelvedOrder,
												  onShelf: onShelf)
	}
	
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								removed: Order,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason) {
		
		self.kitchenModuleDelegate?.kitchenModule(kitchenModule: self,
												  removed: removed,
												  fromShelf: fromShelf,
												  reason: reason)
	}
}
