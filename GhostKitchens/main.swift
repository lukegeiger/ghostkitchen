//
//  main.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/15/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

if let path = Bundle.main.path(forResource: "orders", ofType: "json") {
	let data = try Data(contentsOf: URL(fileURLWithPath: path),
						options: .mappedIfSafe)
	
	let decoder = JSONDecoder()
	let sampleOrders = try decoder.decode([Order].self,
									  from: data)
	
	let kitchen = sampleKitchen()
	
	let simulation = Simulation(orders: sampleOrders,
								ghostKitchen: kitchen,
								ingestionRate: 5)
	simulation.begin()
}

func sampleKitchen() -> GhostKitchen {
	let shelf1 = Shelf(name: "Hot Shelf",
					   allowedTemperature: .hot,
					   capacity: 10,
					   currentOrders: [])

	let shelf2 = Shelf(name: "Cold Shelf",
					   allowedTemperature: .cold,
					   capacity: 10,
					   currentOrders: [])

	let shelf3 = Shelf(name: "Frozen Shelf",
					   allowedTemperature: .frozen,
					   capacity: 10,
					   currentOrders: [])

	let shelf4 = Shelf(name: "Overflow Shelf",
					   allowedTemperature: .any,
					   capacity: 15,
					   currentOrders: [])
			
	let courierDispatcher = CourierDispatcher()
	let routeSimulator = CourierRouter()
	
	let deliveryModule = DeliveryModule(courierDispatcher: courierDispatcher,
										courierRouter: routeSimulator)
	
	let orderCooker = OrderCooker()

	let decayMonitor = OrderDecayMonitor()
	let shelveOrderDistributor = ShelveOrderDistributor(shelves: [shelf1,shelf2,shelf3,shelf4],
														decayMonitor: decayMonitor)

	let kitchenModule = KitchenModule(orderCooker: orderCooker,
									  shelveOrderDistributor: shelveOrderDistributor)
	
	let ghostKitchen = GhostKitchen(kitchenModule: kitchenModule,
									deliveryModule: deliveryModule)
	return ghostKitchen
}







