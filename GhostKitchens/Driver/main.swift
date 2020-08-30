//
//  main.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/15/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

let simulation = Simulation(orders: Simulation.parseOrdersToSimulate(),
							ghostKitchen: GhostKitchen.sampleKitchen(),
							ingestionRate: 20)

simulation.simulationTimer.activate()

RunLoop.current.run()
