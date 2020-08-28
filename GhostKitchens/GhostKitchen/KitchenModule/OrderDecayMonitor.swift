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
	private var orderAgeDictionary: [String : Float] = [:]
}

// MARK: OrderDecayMonitoring Implementation

extension OrderDecayMonitor {
	
	func beginMonitoring() {
		let timer = Timer.scheduledTimer(timeInterval: 1,
											 target: self,
											 selector: #selector(updateOrdersAges),
											 userInfo: nil,
											 repeats: true)
		RunLoop().add(timer,
					  forMode: .default)
	}
}

// MARK: OrderDecayMonitor Private Functions

extension OrderDecayMonitor {
	
	@objc private func updateOrdersAges() {
		
		if let dataSource = self.orderDecayMonitorDataSource {
			let monitoringOrders = Shelf.orders(fromShelves: dataSource.monitoringShelves())
	
			monitoringOrders.forEach({[unowned self] (order) in
				
				if let currentAgeOfOrder = orderAgeDictionary[order.id] {
					orderAgeDictionary[order.id] = currentAgeOfOrder + 1.0
					let decay = self.decayOf(order: order,
											 ageOfOrder: currentAgeOfOrder + 1)
					
					orderDecayDictionary[order.id] = decay

					if decay <= 0 {
						orderAgeDictionary[order.id] = nil
						orderDecayDictionary[order.id] = nil
						self.orderDecayMonitorDelegate?.orderDecayMonitor(monitor: self,
																		  detectedDecayedOrder: order)
					}
				} else {
					orderAgeDictionary[order.id] = 1.0
					orderDecayDictionary[order.id] = 1.0
				}
			})
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
				  ageOfOrder: Float) -> Float {
		
		if let shelf = self.orderDecayMonitorDataSource?.monitoringShelves().first(where: {$0.currentOrders.contains(order)}) {
			return Float.calculateOrderDecay(shelfLife: Float(order.shelfLife),
											 orderAge: ageOfOrder,
											 decayRate: order.decayRate,
											 shelfDecayModifier: Float(shelf.shelfDecayModifier))
		}
		return 0.0
	}
}
