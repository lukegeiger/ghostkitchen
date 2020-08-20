//
//  GhostKitchen+DebugTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens

class GhostKitchenDebugTests: XCTestCase {

    func testSampleKitchen() throws {
		
		let sampleKitchen = GhostKitchen.sampleKitchen()
		XCTAssertNotNil(sampleKitchen.kitchenModule)
		XCTAssertNotNil(sampleKitchen.deliveryModule)
    }
}
