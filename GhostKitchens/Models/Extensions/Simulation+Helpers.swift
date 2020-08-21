//
//  Simulation+Helpers.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/21/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: Simulation Helpers

extension Simulation {
	
    /**
	 Returns an array of parsed orders from the orders.json file in the project.
     */
	static func parseOrdersToSimulate() -> [Order] {
		
		if let path = Bundle.main.path(forResource: "orders", ofType: "json") {
			
			guard let sampleOrders = try? JSONDecoder().decode([Order].self,
															   from: try Data(contentsOf: URL(fileURLWithPath: path))) else {
																return []
			}
			return sampleOrders
		}
		return []
	}
}


