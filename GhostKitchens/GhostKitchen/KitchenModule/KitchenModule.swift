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
	
	func kitchenModule(kitchenModule: KitchenModule,
				 receivedOrders: [Order])
	
	func kitchenModule(kitchenModule: KitchenModule,
						cooked: [Order])
	
	func kitchenModule(kitchenModule: KitchenModule,
								shelvedOrder: Order,
								onShelf: Shelf)
	
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
        - orderCooker: A kitchen module
        - shelveOrderDistributor: a delivery Module

     - Returns: A kitchen ready to make some bomb food!
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
