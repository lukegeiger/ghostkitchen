//
//  SimulationTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/21/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class SimulationTests: XCTestCase {

    func testSimulation() throws {
		
		let hotOrder = Order(id: "1",
							 name: "Hot Burger",
							 temp: .hot,
							 shelfLife: 10,
							 decayRate: 0.0)
		
		let coldOrder = Order(id: "2",
							  name: "Cold Drink",
							  temp: .cold,
							  shelfLife: 10,
							  decayRate: 0.0)
		
		let simulation = Simulation(orders: [hotOrder, coldOrder],
									ghostKitchen: GhostKitchen.sampleKitchen(),
									ingestionRate: 2)
		
		simulation.simulationTimer.activate()
		simulation.dispatchNextBatchOfOrders()
		XCTAssertTrue(simulation.simulationTimer.isCancelled == false)
		simulation.dispatchNextBatchOfOrders()
		XCTAssertTrue(simulation.simulationTimer.isCancelled)
    }
	
    func testSimulationNoOrder() throws {
		
		let emptyOrders = Simulation.parseOrdersToSimulate()
		XCTAssertTrue(emptyOrders.count == 0)
    }
}
