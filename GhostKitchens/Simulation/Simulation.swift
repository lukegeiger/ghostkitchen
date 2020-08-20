//
//  Simulation.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

final class Simulation {
	
	private let ingestionRate: Int
	private let ghostKitchen: GhostKitchen
	private var remainingOrdersInSimulation: [Order]

	init(orders: [Order],
		 ghostKitchen: GhostKitchen,
		 ingestionRate: Int) {
		
		self.remainingOrdersInSimulation = orders
		self.ingestionRate = ingestionRate
		self.ghostKitchen = ghostKitchen
	}
	
	func begin() {
		
		let timer = Timer.scheduledTimer(timeInterval: 1,
											 target: self,
											 selector: #selector(dispatchNextBatchOfOrders),
											 userInfo: nil,
											 repeats: true)			
		RunLoop().add(timer, forMode: .default)
		RunLoop.current.run()
	}
	
	@objc private func dispatchNextBatchOfOrders() {
		
		if self.remainingOrdersInSimulation.count > 0 {
			let ordersToBeDispatched = Array(self.remainingOrdersInSimulation.prefix(self.ingestionRate))
			self.ghostKitchen.kitchenModule.receive(orders: ordersToBeDispatched)
			self.remainingOrdersInSimulation = Array(remainingOrdersInSimulation.dropFirst(self.ingestionRate))
		}
	}
}
