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
	let simulationTimer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.gk.simqueue"))
	
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
		self.simulationTimer.schedule(deadline: .now(), repeating: 1.0)
		self.simulationTimer.setEventHandler { [unowned self] in
			print("running")
			self.dispatchNextBatchOfOrders()
		}
	}
}

// MARK: Public API
extension Simulation {
	
	/**
	Begins the simulation with the specified parameters taken in the init
	
	- Parameters:
	- addToRunLoop: Used for testing. Default is YES.
	*/
	func begin(addToRunLoop: Bool = true) {
		self.simulationTimer.activate()
	}
	
	/**
	Stops the timer from firing
	*/
	func end() {
		self.simulationTimer.cancel()
	}
}

// MARK: Public API

extension Simulation {
	
	@objc func dispatchNextBatchOfOrders() {
		
		if self.remainingOrdersInSimulation.count > 0 {
			self.ghostKitchen.kitchenModule.receive(orders: Array(self.remainingOrdersInSimulation.prefix(self.ingestionRate)))
			self.remainingOrdersInSimulation = Array(self.remainingOrdersInSimulation.dropFirst(self.ingestionRate))
		} else {
			self.end()
		}
	}
}
