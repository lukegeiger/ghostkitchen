//
//  OrderDecayMonitor.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: OrderDecayMonitoring

protocol OrderDecayMonitoring: class {
	
    /**
		Begins monitoring for order decay
     */
	func beginMonitoring()
	var orderDecayDictionary: [String : Float] {get set}
	var orderDecayMonitorDataSource: OrderDecayMonitorDataSource? { get set }
	var orderDecayMonitorDelegate: OrderDecayMonitorDelegate? { get set }
}

// MARK: OrderDecayMonitorDelegate

protocol OrderDecayMonitorDelegate: class {
	
    /**
     A delegate callback that lets the consumer know when an order has decayed.

     - Parameters:
        - monitor: The monitor that detected the decay
        - detectedDecayedOrder: The decayed order
     */
	func orderDecayMonitor(monitor: OrderDecayMonitor,
						   detectedDecayedOrder: Order)
}

// MARK: OrderDecayMonitorDataSource

protocol OrderDecayMonitorDataSource: class {
	
    /**
     The shelves that the OrderDecayMonitor will monitor for decay.
     */
	func monitoringShelves() -> [Shelf]
}

// MARK: OrderDecayMonitor

final class OrderDecayMonitor: OrderDecayMonitoring {
	
	weak var orderDecayMonitorDataSource: OrderDecayMonitorDataSource?
	weak var orderDecayMonitorDelegate: OrderDecayMonitorDelegate?
	var orderDecayDictionary: [String : Float] = [:]
	let decayQueue = DispatchQueue(label: "com.gk.decayQueue")
	private var orderAgeDictionary: [String : Float] = [:]
	private let decayTimer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.gk.decaytimer"))
}

// MARK: OrderDecayMonitoring Implementation

extension OrderDecayMonitor {
	
	func beginMonitoring() {
		self.decayTimer.activate()
		self.decayTimer.schedule(deadline: .now(), repeating: 1.0)
		self.decayTimer.setEventHandler { [unowned self] in
			self.updateOrdersAges()
		}
	}
}

// MARK: OrderDecayMonitor Private Functions

extension OrderDecayMonitor {
	
	@objc private func updateOrdersAges() {
		
		self.decayQueue.sync {
				if let dataSource = self.orderDecayMonitorDataSource {
					let shelves = dataSource.monitoringShelves()

					let monitoringOrders = Shelf.orders(fromShelves: shelves)
			
					monitoringOrders.forEach({[unowned self] (order) in
						
						if let currentAgeOfOrder = orderAgeDictionary[order.id] {
							self.orderAgeDictionary[order.id] = currentAgeOfOrder + 1.0
							
							let decay = self.decayOf(order: order,
													 availableShelves: shelves,
													 ageOfOrder: currentAgeOfOrder + 1)
							
							self.orderDecayDictionary[order.id] = decay

							if decay <= 0 {
								self.orderAgeDictionary[order.id] = nil
								self.orderDecayDictionary[order.id] = nil
								self.orderDecayMonitorDelegate?.orderDecayMonitor(monitor: self,
																				  detectedDecayedOrder: order)
							}
						} else {
							self.orderAgeDictionary[order.id] = 1.0
							self.orderDecayDictionary[order.id] = 1.0
						}
					})
				}
		}
	}
}

extension OrderDecayMonitor {
    /**
	 Calculates the decay of the order

     - Parameters:
        - order: The order to measure decay.
        - ageOfOrder: The tracked age of the order
     */
	func decayOf(order: Order,
				 availableShelves: [Shelf],
				  ageOfOrder: Float) -> Float {
		
		if let shelf = availableShelves.first(where: {$0.currentOrders.contains(order)}) {
			return Float.calculateOrderDecay(shelfLife: Float(order.shelfLife),
											 orderAge: ageOfOrder,
											 decayRate: order.decayRate,
											 shelfDecayModifier: Float(shelf.shelfDecayModifier))
		}
		return 0.0
	}
}
