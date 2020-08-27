//
//  GhostRestaurant.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

final class GhostKitchen {
	
	/// kitchenModule is responsible for all things related to cooking and managing the health & decay of an order.
	let kitchenModule: KitchenModule
	
	/// deliveryModule is responsible for all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.
	let deliveryModule: DeliveryModule

    /**
     Initializes a new GhostKtichen that can accept and deliver food orders.

     - Parameters:
        - kitchenModule: A kitchen module
        - deliveryModule: a delivery Module

     - Returns: An awesome kitchen ready to take over the world
     */
	init(kitchenModule: KitchenModule,
		 deliveryModule: DeliveryModule) {
		
		self.kitchenModule = kitchenModule
		self.deliveryModule = deliveryModule		
		self.kitchenModule.kitchenModuleDelegate = self
		self.deliveryModule.deliveryModuleDelegate = self
	}	
}

// MARK: KitchenModuleDelegate

extension GhostKitchen: KitchenModuleDelegate {

	func kitchenModule(kitchenModule: KitchenModule,
					   shelvedOrder: Order,
					   onShelf: Shelf) {
		
		print("Shelved: " + shelvedOrder.name + " " + shelvedOrder.id + " on " + onShelf.name)
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   cooked: [Order]) {
		cooked.forEach { (order) in
			print("Order: " + order.name + " " + order.id + " cooked" )
		}
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
				 receivedOrders: [Order]) {
		
		receivedOrders.forEach { [weak self] (order) in
			print("Order: " + order.name + " " + order.id + " Received")
			self?.kitchenModule.shelveOrderDistributor.printShelfContents()
		}
		
		self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
								removed: Order,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason) {
	
		switch reason {
			case .courierPickup:
				print("Order: " + removed.id + " removed from " + fromShelf.name)
				break
			case .decay:
				print("Order: " + removed.id + " decayed from " + fromShelf.name)
				break
			case .overflow:
				print("Order: " + removed.id + " discarded from " + fromShelf.name)
				break
			}
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
}

// MARK: DeliveryModuleDelegate

extension GhostKitchen: DeliveryModuleDelegate {
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrder: Order,
						onRoute: Route) {
		print("Courier: " + courier.id + " picking up order " + arrivedForOrder.name + " " + arrivedForOrder.id)
		self.kitchenModule.shelveOrderDistributor.remove(orders: [arrivedForOrder],
														 reason: .courierPickup)
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier,
						forOrder: Order) {
		print("Courier: " + routed.id + " routed for order " + forOrder.name + " " + forOrder.id)
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrder: Order) {
		print("Courier: " + courier.id + " dropped off order " + deliveredOrder.name + " " + deliveredOrder.id)
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
}
