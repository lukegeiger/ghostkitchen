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

	private var couriersInLine:[Courier] = []
	
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
				 receivedOrders: [Order]) {
		
		receivedOrders.forEach { [weak self] (order) in
			print("Order: " + order.name + " " + order.id + " received and started to cook")
			self?.kitchenModule.shelveOrderDistributor.printShelfContents()
		}
		
		DispatchQueue.global(qos: .background).async { [weak self] in
			self?.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
		}
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   cooked: [Order]) {
		
		cooked.forEach { (order) in
			print("Order: " + order.name + " " + order.id + " cooked" )
		}
	}
	
	func kitchenModule(kitchenModule: KitchenModule,
					   shelvedOrder: Order,
					   onShelf: Shelf) {
		
		print("Shelved: " + shelvedOrder.name + " " + shelvedOrder.id + " on " + onShelf.name)
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
		
		// If the orders took longer than expected to cook, there might be a courier waiting for it already
		if let potentiallyWaitingCourier = self.couriersInLine.first(where: {$0.schedule.tasks.contains(where: {$0.type == .pickup && $0.orderId == shelvedOrder.id})}) {
			
			DispatchQueue.global(qos: .background).async { [unowned self] in
				self.pickupOrderAndBeginDropoff(order: shelvedOrder.id,
												courier: potentiallyWaitingCourier)
				self.couriersInLine.remove(at: self.couriersInLine.firstIndex(of: potentiallyWaitingCourier)!)
			}

		}
	}
		
	func kitchenModule(kitchenModule: KitchenModule,
								removedOrderId: String,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason) {
		
		switch reason {
			case .courierPickup:
				print("Order: " + removedOrderId + " removed from " + fromShelf.name)
				break
			case .decay:
				print("Order: " + removedOrderId + " decayed from " + fromShelf.name)
				break
			case .overflow:
				print("Order: " + removedOrderId + " discarded from " + fromShelf.name)
				break
			}
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
}

// MARK: DeliveryModuleDelegate

extension GhostKitchen: DeliveryModuleDelegate {
	
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier,
						forOrder: Order) {
		
		DispatchQueue.global(qos: .background).async {
			deliveryModule.courierRouter.commencePickupRoute(courier: routed)
		}
		print("Courier: " + routed.id + " routed for order " + forOrder.id)
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrderId: String,
						onRoute: String) {
		
		print("Courier: " + courier.id + " arriving at restaurant for order " + arrivedForOrderId)
		
		// ensure the order was cooked and shelved before we can distribute to a courier
		if self.kitchenModule.shelveOrderDistributor.shelvedOrderIds().contains(arrivedForOrderId) {
			DispatchQueue.global(qos: .background).async { [unowned self] in
				self.pickupOrderAndBeginDropoff(order: arrivedForOrderId,
											  courier: courier)
			}

		} else {
			print("Courier: " + courier.id + " waiting at restaurant for order " + arrivedForOrderId)
			self.couriersInLine.append(courier)
		}
	}
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrderId: String) {
		
		print("Courier: " + courier.id + " dropped off order " + deliveredOrderId)
		self.kitchenModule.shelveOrderDistributor.printShelfContents()
	}
}

// MARK: Private API

extension GhostKitchen {
	
	private func pickupOrderAndBeginDropoff(order: String,
											courier: Courier) {
		print("Courier: " + courier.id + " picking up order " + order)
		self.kitchenModule.shelveOrderDistributor.remove(orderIds: [order],
														 reason: .courierPickup)
		deliveryModule.courierRouter.commenceDropoffRoute(courier: courier)
	}
}
