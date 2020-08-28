//
//  OrderDistributor.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

/**
 ShelveOrderDistributorRemovalReason are reasons why an order would be removed from a shelf.
*/
enum ShelveOrderDistributorRemovalReason: String {
	
	case courierPickup // for when a courier picked up an order
	case overflow // forced overflow
	case decay // order decayed away
}

// MARK: ShelveOrderDistributorDelegate

protocol ShelveOrderDistributorDelegate: class {
	
    /**
     A delegate callback that lets a consumer know when the shelveOrderDistributor shelved an order.

     - Parameters:
        - shelveOrderDistributor: An instance of the shelveOrderDistributor that performed the shelve
        - shelvedOrder: The order shelved
        - onShelf: The shelf the order was placed
     */
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								shelvedOrder: Order,
								onShelf: Shelf)
		
    /**
     A delegate callback that lets a consumer know when an order was removed from a shelf and why

     - Parameters:
        - shelveOrderDistributor: An instance of the shelveOrderDistributor that performed the shelve
        - removedOrderId: The removed order id
        - fromShelf: The shelf the order was removed from
        - reason: Why the order was removed.
     */
	func shelveOrderDistributor(shelveOrderDistributor: ShelveOrderDistributor,
								removedOrderId: String,
								fromShelf: Shelf,
								reason: ShelveOrderDistributorRemovalReason)
}

// MARK: ShelveOrderDistributing

protocol ShelveOrderDistributing: class {
	
    /**
     Will shelf the order on the best possible shelf for the order.

     - Parameters:
        - orders: Orders to be shelved
     */
	func shelve(orders: [Order])
	
    /**
		Will remove orders from the shelves they are on.

     - Parameters:
        - orderIds: IDs of Orders to be removed
        - reason: Why the orders are removed
     */
	func remove(orderIds: [String],
				reason: ShelveOrderDistributorRemovalReason)
	
    /**
     Will give you the shelf the order is on if there is one.

     - Parameters:
        - forOrderId: Given this order id, will give you its shelf.
     */
	func shelf(forOrderId: String) -> Shelf?
		
    /**
		Prints the contents of the shelf.
     */
	func printShelfContents()
	
    /**
     Initializes a new ShelveOrderDistributor that will be responsible for shelving and monitoring order health.

     - Parameters:
        - shelves: The shelves to manage
        - decayMonitor: A monitor to detect decaying orders

     - Returns: A ShelveOrderDistributor
     */
	init(shelves: [Shelf],
		 decayMonitor: OrderDecayMonitoring)
	
	var shelveOrderDistributorDelegate: ShelveOrderDistributorDelegate? { get set }
}

// MARK: ShelveOrderDistributor

final class ShelveOrderDistributor: ShelveOrderDistributing {

	weak var shelveOrderDistributorDelegate: ShelveOrderDistributorDelegate?
	
	let shelves: [Shelf]
	var orderDecayMonitor: OrderDecayMonitoring

	required init(shelves: [Shelf],
				  decayMonitor: OrderDecayMonitoring) {
		self.shelves = shelves
		self.orderDecayMonitor = decayMonitor
		self.orderDecayMonitor.orderDecayMonitorDelegate = self
		self.orderDecayMonitor.orderDecayMonitorDataSource = self
		self.orderDecayMonitor.beginMonitoring()
	}
}

// MARK: ShelveOrderDistributing Implementation

extension Array {
    mutating func modifyForEach(_ body: (_ index: Index, _ element: inout Element) -> ()) {
        for index in indices {
            modifyElement(atIndex: index) { body(index, &$0) }
        }
    }

    mutating func modifyElement(atIndex index: Index, _ modifyElement: (_ element: inout Element) -> ()) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
    }
}

extension ShelveOrderDistributor {
		
	func shelve(orders: [Order]) {
		
		let shelveQueue = DispatchQueue(label: "com.gk.shelving")
		// critical section
		shelveQueue.sync {
		
			orders.forEach { [unowned self] (order) in
				
				if var preferredShelf = self.shelves.first(where: {$0.allowedTemperature == order.temp && $0.isFull() == false}) {
					
					// First choice
					preferredShelf.currentOrders.append(order)
					self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																				shelvedOrder: order,
																				onShelf: preferredShelf)
					
				} else if var preferredOverflowShelf = self.shelves.first(where: {$0.allowedTemperature == .any && $0.isFull() == false}) {
					
					// 2nd choice
					preferredOverflowShelf.currentOrders.append(order)
					self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																				shelvedOrder: order,
																				onShelf: preferredOverflowShelf)
					
				} else if var forcedOverflowShelf = self.shelves.first(where: {$0.allowedTemperature == .any && $0.isFull() == true}) {
					
					// 3rd and forced choice
					if let firstOrderOnOverflow = forcedOverflowShelf.currentOrders.first {
						self.remove(orderIds: [firstOrderOnOverflow.id],
									reason: .overflow)
					}

					forcedOverflowShelf.currentOrders.append(order)
					
					self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																				shelvedOrder: order,
																				onShelf: forcedOverflowShelf)
				}
			}
		}
	}
	
	func remove(orderIds: [String],
				reason:ShelveOrderDistributorRemovalReason) {
		
		let removeQueue = DispatchQueue(label: "com.gk.removing")
		
		// critical section
		removeQueue.sync {
			orderIds.forEach { [unowned self] (orderId) in
				if var shelfForOrder = self.shelf(forOrderId: orderId) {
					shelfForOrder.currentOrders.removeAll(where: {$0.id	== orderId})
					self.shelveOrderDistributorDelegate?.shelveOrderDistributor(shelveOrderDistributor: self,
																				removedOrderId: orderId,
																				fromShelf: shelfForOrder,
																				reason: reason)
				}
			}
		}
	}
	
	// of all the shelves, find the one where its current orders as an orderId equal to forOrderId
	
	func shelf(forOrderId: String) -> Shelf? {
		return self.shelves.first(where: {$0.currentOrders.contains(where: {$0.id == forOrderId})})
	}
	
	func printShelfContents() {
		print("")
		self.shelves.forEach { (shelf) in
			shelf.printShelf(orderDecayInfo: self.orderDecayMonitor.orderDecayDictionary)
			print("________________________________")
		}
		print("")
	}
}

extension ShelveOrderDistributor: OrderDecayMonitorDelegate {
		
	func orderDecayMonitor(monitor: OrderDecayMonitor,
						   detectedDecayedOrder: Order) {
		
		self.remove(orderIds: [detectedDecayedOrder.id],
					reason: .decay)
	}
}

extension ShelveOrderDistributor: OrderDecayMonitorDataSource {
	
	func monitoringShelves() -> [Shelf] {

		self.shelves
	}
}
