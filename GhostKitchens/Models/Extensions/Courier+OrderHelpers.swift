//
//  Courier+OrderHelpers.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/19/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: Courier Helpers

extension Courier {
	
    /**
     Creates a Courier model to deliver the passed in order.

     - Parameters:
        - order: The order that needs to be delivered

     - Returns: The courier to deliver the order
     */
	static func createCourierForOrder(order: Order) -> Courier {

		let pickupTask = Task(type: .pickup,
							  duration: Int.random(in: 2...6),
							  orderId: order.id)
		
		let dropoffTask = Task(type: .dropoff,
							   duration: 0,
							   orderId: order.id)

		let schedule = Schedule(scheduleId: UUID().uuidString,
								tasks: [pickupTask,dropoffTask])

		let courier = Courier(id: UUID().uuidString,
							  schedule: schedule)
		
		return courier
	}
}
