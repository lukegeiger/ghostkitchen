//
//  Simulation+Helpers.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/21/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

extension Simulation {
	
    /**
		Pulls in orders from orders.json Note this does not work in unit tests and will return an empty array.

     - Returns: An array of parsed orders
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


