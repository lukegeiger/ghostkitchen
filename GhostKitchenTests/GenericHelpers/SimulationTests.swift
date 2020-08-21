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
		
		let simulation = Simulation(orders: [],
									ghostKitchen: GhostKitchen.sampleKitchen(),
									ingestionRate: 2)
		
		simulation.begin(addToRunLoop: false)
		XCTAssertTrue(simulation.simulationTimer != nil)
		simulation.end()
		XCTAssertTrue(simulation.simulationTimer == nil)
    }
}
