//
//  OrderTests.swift
//  GhostKitchenTests
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import XCTest
@testable import GhostKitchens


class OrderTests: XCTestCase {
	
	func testEquality() throws {
		
		let order1 = Order(id: "1",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		
		let order2 = Order(id: "2",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		
		XCTAssertTrue(order1 != order2)
		
		let order3 = Order(id: "1",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		
		XCTAssertTrue(order3 == order1)
    }
	
	func testParsing() throws {
		
		let file = try TestingResource(name: "orders",
									   type: "json")
		
		let data = try Data(contentsOf: URL(fileURLWithPath: file.url.path),
							options: .mappedIfSafe)
		
		let decoder = JSONDecoder()
		let sampleOrders = try decoder.decode([Order].self,
										  from: data)
		
		
		print(sampleOrders.count)
		XCTAssertTrue(sampleOrders.count == 132)
		
		let firstOrder = sampleOrders.first
		XCTAssertNotNil(firstOrder)
		
		if let firstOrder = firstOrder {
			XCTAssertTrue(firstOrder.id == "a8cfcb76-7f24-4420-a5ba-d46dd77bdffd")
			XCTAssertTrue(firstOrder.name == "Banana Split")
			XCTAssertTrue(firstOrder.temp == .frozen)
			XCTAssertTrue(firstOrder.shelfLife == 20)
			XCTAssertTrue(firstOrder.decayRate == 0.63)
		}
	}
	
	func testParsingMalformed() throws {
		
		let file = try TestingResource(name: "malformed-orders", type: "json")
		
		let data = try Data(contentsOf: URL(fileURLWithPath: file.url.path),
							options: .mappedIfSafe)
		
		let decoder = JSONDecoder()
		
		let sampleOrders = try? decoder.decode([Order].self,
											  from: data)
		
		XCTAssertNil(sampleOrders)
	}
	
	func testDescription() throws {
		let order1 = Order(id: "1",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		order1.decay = 0.6
		
		let order1Description = order1.description
		XCTAssertTrue(order1Description == "Order(id: 1 name: Nemo Burger, temp: hot, shelfLife: 1, decayRate: 0.0 , decay: Optional(0.6)")

		
		let order2 = Order(id: "1",
						   name: "Nemo Burger",
						   temp: .hot,
						   shelfLife: 1,
						   decayRate: 0)
		
		let order2Description = order2.description
		XCTAssertTrue(order2Description == "Order(id: 1 name: Nemo Burger, temp: hot, shelfLife: 1, decayRate: 0.0 , decay: nil")
	}
	
}

struct TestingResource {
  let name: String
  let type: String
  let url: URL

  init(name: String,
	   type: String,
	   sourceFile: StaticString = #file) throws {
    self.name = name
    self.type = type

    let testCaseURL = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
    let testsFolderURL = testCaseURL.deletingLastPathComponent()
    let resourcesFolderURL = testsFolderURL.deletingLastPathComponent().appendingPathComponent("AppResources", isDirectory: true)
    self.url = resourcesFolderURL.appendingPathComponent("\(name).\(type)", isDirectory: false)
  }
}
