//
//  OrderDistributor.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

enum ShelveOrderDistributorRemovalReason {
	
	case courierPickup
	case overflow
	case decay
}

// MARK: ShelveOrderDistributorDelegate

protocol ShelveOrderDistributorDelegate {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
        - forRoute: The handlebar of the bicycle
     */
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								shelvedOrder: Order,
								onShelf: Shelf)
		
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
        - forRoute: The handlebar of the bicycle
        - forOrder: The frame size of the bicycle, in centimeters
     */
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								removed: Order,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason)
}

// MARK: ShelveOrderDistributing

protocol ShelveOrderDistributing {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
     */
	func shelve(orders: [Order])
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
     */
	func remove(orders: [Order],
				reason: ShelveOrderDistributorRemovalReason)
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
     */
	func shelf(forOrder: Order) -> Shelf?
		
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.
     */
	func printShelfContents()
	
    /**
     Initializes a new KitchenModule that will be responsible for cooking, and manging the health of an order.

     - Parameters:
        - orderCooker: A kitchen module
        - shelveOrderDistributor: a delivery Module

     - Returns: A kitchen ready to make some bomb food!
     */
	init(shelves: [Shelf],
		 decayMonitor: OrderDecayMonitor)
	
	/// Some Documentation
	var shelveOrderDistributorDelegate: ShelveOrderDistributorDelegate? { get set }
}

// MARK: ShelveOrderDistributor

final class ShelveOrderDistributor:ShelveOrderDistributing {

	var shelveOrderDistributorDelegate: ShelveOrderDistributorDelegate?
	
	let shelves: [Shelf]
	let orderDecayMonitor: OrderDecayMonitor

	required init(shelves: [Shelf],
				  decayMonitor: OrderDecayMonitor) {
		self.shelves = shelves
		self.orderDecayMonitor = decayMonitor
		self.setup()
	}

	private func setup() {
		
		self.orderDecayMonitor.orderDecayMonitorDelegate = self
		self.orderDecayMonitor.orderDecayMonitorDataSource = self
		self.orderDecayMonitor.beginMonitoring()
	}
}

// MARK: ShelveOrderDistributing Implementation

extension ShelveOrderDistributor {
		
	func shelve(orders: [Order]) {
		
		orders.forEach { (order) in
			if let preferredShelf = self.shelves.first(where: {$0.allowedTemperature == order.temp && $0.isFull() == false}) {
				preferredShelf.currentOrders.append(order)
				self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																			shelvedOrder: order,
																			onShelf: preferredShelf)
			} else if let preferredOverflowShelf = self.shelves.first(where: {$0.allowedTemperature == .any && $0.isFull() == false}) {
				preferredOverflowShelf.currentOrders.append(order)
				self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																			shelvedOrder: order,
																			onShelf: preferredOverflowShelf)
			} else if let forcedOverflowShelf = self.shelves.first(where: {$0.allowedTemperature == .any && $0.isFull() == true}) {
				
				if let firstOrderOnOverflow = forcedOverflowShelf.currentOrders.first {
					self.remove(orders: [firstOrderOnOverflow],
								reason: .overflow)
				}

				forcedOverflowShelf.currentOrders.append(order)
				
				self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																			shelvedOrder: order,
																			onShelf: forcedOverflowShelf)
			}
		}
	}
	
	func remove(orders: [Order],
				reason:ShelveOrderDistributorRemovalReason) {
		
		orders.forEach { (order) in
			if let shelfForOrder = self.shelf(forOrder: order) {
				if shelfForOrder.currentOrders.contains(order) {
					shelfForOrder.currentOrders.removeAll(where: {$0.id	== order.id})
					self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																				removed: order,
																				fromShelf: shelfForOrder,
																				reason: reason)
				}
			}
		}
	}
	
	func shelf(forOrder: Order) -> Shelf? {
		
		return self.shelves.first(where: {$0.currentOrders.contains(forOrder)})
	}
	
	func printShelfContents() {
		
		self.shelves.forEach { (shelf) in
			print("______________________")
			shelf.printShelf()
			print("______________________")
		}
	}
}

extension ShelveOrderDistributor: OrderDecayMonitorDelegate {
	
	func orderDecayMonitor(monitor: OrderDecayMonitor,
						   detectedDecayedOrder: Order) {
		self.remove(orders: [detectedDecayedOrder],
					reason: .decay)
	}
}

extension ShelveOrderDistributor: OrderDecayMonitorDataSource {
	
	func monitoringShelves() -> [Shelf] {
		self.shelves
	}
}
