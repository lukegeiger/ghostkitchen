//
//  Simulation.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

/**
 Represents a GhostKitchen Simulation
 */
final class Simulation {
	
	private let ingestionRate: Int
	private let ghostKitchen: GhostKitchen
	private var remainingOrdersInSimulation: [Order]
	private var simulationTimer: Timer?
	
    /**
     Initializes a new simulation

     - Parameters:
        - orders: The orders to be simulated into the kitchen
        - ghostKitchen: The kitchen to be in the simulation
		- ingestionRate: how many order per second are ingested into the kitchen
     */
	init(orders: [Order],
		 ghostKitchen: GhostKitchen,
		 ingestionRate: Int) {
		
		self.remainingOrdersInSimulation = orders
		self.ingestionRate = ingestionRate
		self.ghostKitchen = ghostKitchen
	}
}

// MARK: Public API
extension Simulation {
    /**
		Begins the simulation
     */
	func begin() {
	
		self.simulationTimer = Timer.scheduledTimer(timeInterval: 1,
											 target: self,
											 selector: #selector(dispatchNextBatchOfOrders),
											 userInfo: nil,
											 repeats: true)
		
		if let simulationTimer = simulationTimer {
			RunLoop().add(simulationTimer,
						  forMode: .default)
			RunLoop.current.run()
		}
	}
	
    /**
		Stops the timer from firing
     */
	func end() {
		
		self.simulationTimer?.invalidate()
		self.simulationTimer = nil
	}
}

// MARK: Private API

extension Simulation {
	
	@objc private func dispatchNextBatchOfOrders() {

		if self.remainingOrdersInSimulation.count > 0 {
			self.ghostKitchen.kitchenModule.receive(orders: Array(self.remainingOrdersInSimulation.prefix(self.ingestionRate)))
			self.remainingOrdersInSimulation = Array(remainingOrdersInSimulation.dropFirst(self.ingestionRate))
		} else {
			self.end()
		}
	}
}
