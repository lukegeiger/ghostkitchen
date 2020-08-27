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
		
		let route = Route(order: order,
						  timeToPickup: Int.random(in: 2...6),
						  timeToDropoff: 0)
		
		let schedule = Schedule(scheduleId: UUID().uuidString,
								routes: [route])

		let courier = Courier(id: UUID().uuidString,
							  schedule: schedule)
		
		return courier
	}
}
