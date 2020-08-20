//
//  main.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/15/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation


if let path = Bundle.main.path(forResource: "orders", ofType: "json") {
	
	let sampleOrders = try JSONDecoder().decode([Order].self,
									  from: try Data(contentsOf: URL(fileURLWithPath: path)))
		
	let simulation = Simulation(orders: sampleOrders,
								ghostKitchen: GhostKitchen.sampleKitchen(),
								ingestionRate: 2)
	
	simulation.begin()
	
} else {
	print("There was an error parsing simulation orders")
}






