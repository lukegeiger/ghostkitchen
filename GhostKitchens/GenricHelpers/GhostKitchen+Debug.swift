//
//  GhostKitchen+Debug.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

extension GhostKitchen {
	
	static func sampleKitchen() -> GhostKitchen {
		
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
}
