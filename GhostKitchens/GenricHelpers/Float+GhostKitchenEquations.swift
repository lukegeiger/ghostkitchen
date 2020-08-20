//
//  Float+GhostKitchenEquations.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

extension Float {
	
    /**
	 Calculates Order Decay

     - Parameters:
        - shelfLife: How long an order can last on a shelf
        - orderAge: Age of order in seconds
        - decayRate: Rate of decay
		- shelfDecayModifier: 2 for overflow shelves 1 for anything else
     */
	static func calculateOrderDecay(shelfLife: Float,
									orderAge: Float,
									decayRate: Float,
									shelfDecayModifier: Float) -> Float {
		
		if shelfDecayModifier <= 0.0 {
			return 0.0
		}
		return max(0,(shelfLife - orderAge - decayRate * orderAge * shelfDecayModifier) / shelfLife)
	}
}
