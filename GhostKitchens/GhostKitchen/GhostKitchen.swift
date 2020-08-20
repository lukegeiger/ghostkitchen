//
//  GhostRestaurant.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

class GhostKitchen {
	
	let kitchenModule: KitchenModule
	let deliveryModule: DeliveryModule

	init(kitchenModule: KitchenModule,
		 deliveryModule: DeliveryModule) {
		
		self.kitchenModule = kitchenModule
		self.deliveryModule = deliveryModule
		self.setup()
	}	
}

// MARK: Private

extension GhostKitchen {
	private func setup() {
		
		self.kitchenModule.kitchenModuleDelegate = self
		self.deliveryModule.deliveryModuleDelegate = self
	}
}

// MARK: KitchenModuleDelegate

extension GhostKitchen: KitchenModuleDelegate {

	func kitchenModule(kitchenModule: KitchenModule,
					   shelvedOrder: Order,
					   onShelf: Shelf) {
		
		print("Shelved: " + shelvedOrder.id + " on shelf " + onShelf.name)
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   cooked: [Order]) {
		// No op
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
				 receivedOrders: [Order]) {
		
		receivedOrders.forEach { (order) in
			print("Order: " + order.id + " Received")
			self.kitchenModule.shelveOrderDistributor.printShelfContents()
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
				self.kitchenModule.shelveOrderDistributor.printShelfContents()
				break
			case .decay:
				print("Order: " + removed.id + " decayed from " + fromShelf.name)
				self.kitchenModule.shelveOrderDistributor.printShelfContents()
				break
			case .overflow:
				print("Order: " + removed.id + " discarded from " + fromShelf.name)
				self.kitchenModule.shelveOrderDistributor.printShelfContents()
				break
			}
	}
}

// MARK: DeliveryModuleDelegate

extension GhostKitchen:DeliveryModuleDelegate {
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrder: Order,
						onRoute: Route) {
		
		print("Courier: " + courier.id + " picking up order " + arrivedForOrder.id)
		self.kitchenModule.shelveOrderDistributor.remove(orders: [arrivedForOrder],
														 reason: .courierPickup)
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier) {
		// no op
	}
		
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrder: Order) {
		
		print("Courier: " + courier.id + " dropped off order " + deliveredOrder.id)
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
}
