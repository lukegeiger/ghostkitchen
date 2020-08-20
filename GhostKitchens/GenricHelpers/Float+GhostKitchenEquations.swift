//
//  Float+GhostKitchenEquations.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

extension Float {
	
	static func calculateOrderDecay(shelfLife: Float,
									orderAge: Float,
									decayRate: Float,
									shelfDecayModifier: Float) -> Float {
		
		if shelfDecayModifier <= 0.0 {
			return 0.0
		}
		return (shelfLife - orderAge - decayRate * orderAge * shelfDecayModifier) / shelfLife
	}
}
