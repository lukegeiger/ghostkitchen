//
//  Float+GhostKitchenEquationsTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class FloatGhostKitchenEquationsTests: XCTestCase {

    func testCalculateOrderDecay() throws {
		
		let decay = Float.calculateOrderDecay(shelfLife: 20.0,
								  orderAge: 1.0,
								  decayRate: 0.63,
								  shelfDecayModifier: 1.0)
	
		XCTAssertTrue(decay == 0.91850007)
    }
	
    func testCalculateOrderDecayNegative() throws {
		
		let decay = Float.calculateOrderDecay(shelfLife: 20.0,
								  orderAge: 21.0,
								  decayRate: 0.63,
								  shelfDecayModifier: 1.0)
		
		XCTAssertTrue(decay == -0.7115)
    }

    func testCalculateOrderDecayAllZeros() throws {
		
		let decay = Float.calculateOrderDecay(shelfLife: 0.0,
											  orderAge: 0.0,
											  decayRate: 0.0,
											  shelfDecayModifier: 0.0)
		
		XCTAssertTrue(decay == 0.0)
    }
	
    func testCalculateOrderDecayNegativeShelfDecay() throws {
		
		let decay = Float.calculateOrderDecay(shelfLife: 20.0,
											  orderAge: 1.0,
											  decayRate: 0.63,
											  shelfDecayModifier: -2.0)
		
		XCTAssertTrue(decay == 0.0)
    }
}

