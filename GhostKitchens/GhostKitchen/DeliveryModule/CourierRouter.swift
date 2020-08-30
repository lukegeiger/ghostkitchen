//
//  RouteSimulator.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: CourierRoutingDelegate

protocol CourierRoutingDelegate: class {
	
    /**
     A delegate callback that lets a consumer know when a courier arrived at a pickup for an order

     - Parameters:
        - courierRouter: An instance of the router that performed the action
        - courierArrivedAtPickup: The courier who arrived
        - forTask: The task the courier arrived at pickup for
        - forOrderId: The id of the order the courier is picking up
     */
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtPickup: Courier,
						   forTask: Task,
						   forOrderId: String)
	
    /**
     A delegate callback that lets a consumer know when a courier dropped off an order

     - Parameters:
        - courierRouter: An instance of the router that performed the action
        - courierArrivedAtDropoff: The courier who arrived at dropoff
        - forTask: The task the courier arrived at dropoff for
        - forOrderId: The id of the order dropping off
     */

	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtDropoff: Courier,
						   forTask: Task,
						   forOrderId: String)
}

// MARK: CourierRouting

protocol CourierRouting: class {
	
    /**
     Begins the pickup process for a courier

     - Parameters:
        - courier: The courier who will begin their pickup route
     */
	func commencePickupRoute(courier: Courier)
	
    /**
     Begins the dropoff process for a courier

     - Parameters:
        - courier: The courier who will begin their dropoff route
     */
	func commenceDropoffRoute(courier: Courier)
	
    /**
		A delegate to recieve routing callbacks
     */
	var courierRoutingDelegate: CourierRoutingDelegate? { get set }
}

// MARK: CourierRouter

final class CourierRouter: CourierRouting {
	
	weak var courierRoutingDelegate: CourierRoutingDelegate?

	func commencePickupRoute(courier: Courier) {

		let pickupTask = courier.schedule.tasks.first(where: {($0.type == .pickup)})
		
		if let pickupTask = pickupTask {
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(pickupTask.duration) , execute: {
				self.courierRoutingDelegate?.courierRouter(courierRouter: self,
																   courierArrivedAtPickup: courier,
																   forTask: pickupTask,
																   forOrderId: pickupTask.orderId)
			})
		}
	}
	
	func commenceDropoffRoute(courier: Courier) {
		
		let dropOffTask = courier.schedule.tasks.first(where: {($0.type == .dropoff)})
		
		if let dropOffTask = dropOffTask {
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(dropOffTask.duration), execute: { 
				self.courierRoutingDelegate?.courierRouter(courierRouter: self,
																   courierArrivedAtDropoff: courier,
																   forTask: dropOffTask,
																   forOrderId: dropOffTask.orderId)
			})
		}
	}
}
