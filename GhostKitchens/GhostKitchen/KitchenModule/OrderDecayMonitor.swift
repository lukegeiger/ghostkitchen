//
//  OrderDecayMonitor.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: OrderDecayMonitoring

protocol OrderDecayMonitoring {
	
	func beginMonitoring()
	var orderDecayMonitorDataSource: OrderDecayMonitorDataSource? { get set }
	var orderDecayMonitorDelegate: OrderDecayMonitorDelegate? { get set }
}

// MARK: OrderDecayMonitorDelegate

protocol OrderDecayMonitorDelegate {
	
	func orderDecayMonitor(monitor:OrderDecayMonitor,
						   detectedDecayedOrder:Order)
}

// MARK: OrderDecayMonitorDataSource

protocol OrderDecayMonitorDataSource {
	
	func monitoringShelves() -> [Shelf]
}

// MARK: OrderDecayMonitor

class OrderDecayMonitor:OrderDecayMonitoring {
	
	var orderDecayMonitorDataSource: OrderDecayMonitorDataSource?
	var orderDecayMonitorDelegate: OrderDecayMonitorDelegate?
	private var orderAgeDictionary:[String:Float] = [:]
}

// MARK: OrderDecayMonitoring Implementation

extension OrderDecayMonitor {
	
	func beginMonitoring() {
		let timer = Timer.scheduledTimer(timeInterval: 1,
											 target: self,
											 selector: #selector(updateOrdersAges),
											 userInfo: nil,
											 repeats: true)
			
		RunLoop().add(timer, forMode: .default)
	}
}

// MARK: OrderDecayMonitor Private Functions

extension OrderDecayMonitor {
	
	@objc private func updateOrdersAges() {
		
		if let dataSource = self.orderDecayMonitorDataSource {
			let monitoringOrders = Shelf.orders(fromShelves: dataSource.monitoringShelves())
	
			monitoringOrders.forEach({ (order) in
				
				if let currentAgeOfOrder = orderAgeDictionary[order.id] {
					orderAgeDictionary[order.id] = currentAgeOfOrder + 1.0
					let decay = self.decayOf(order: order,
											 ageOfOrder: currentAgeOfOrder + 1)
					if decay <= 0 {
						orderAgeDictionary[order.id] = nil
						self.orderDecayMonitorDelegate?.orderDecayMonitor(monitor: self,
																		  detectedDecayedOrder: order)
					}
				} else {
					orderAgeDictionary[order.id] = 1.0
				}
			})
		}
	}

	private func decayOf(order:Order,
				  ageOfOrder:Float) -> Float {
		
		if let shelf = self.orderDecayMonitorDataSource?.monitoringShelves().first(where: {$0.currentOrders.contains(order)}) {
			return Float.calculateOrderDecay(shelfLife: Float(order.shelfLife),
											   orderAge: ageOfOrder,
									          decayRate: order.decayRate,
									  shelfDecayModifier: Float(shelf.shelfDecayModifier))
		}
		return -1
	}
}
