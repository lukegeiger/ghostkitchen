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
        - forRoute: The route the courier is on
        - forOrderId: The id of the order the courier is picking up
     */
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtPickup: Courier,
						   forRoute: Route,
						   forOrderId: String)
	
    /**
     A delegate callback that lets a consumer know when a courier dropped off an order

     - Parameters:
        - courierRouter: An instance of the router that performed the action
        - courierArrivedAtDropoff: The courier who arrived at dropoff
        - forRoute: The route the courier took
        - forOrderId: The id of the order dropping off
     */

	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtDropoff: Courier,
						   forRoute: Route,
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
		
		courier.schedule.routes.forEach {[weak self] (route) in
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(route.timeToPickup), execute: {
				guard let self = self else {
				  return
				}
				self.courierRoutingDelegate?.courierRouter(courierRouter: self,
																   courierArrivedAtPickup: courier,
																   forRoute:route,
																   forOrderId: route.orderId)
			})
		}
	}
	
	func commenceDropoffRoute(courier: Courier) {
		
		courier.schedule.routes.forEach {[weak self] (route) in
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(route.timeToDropoff), execute: {
				guard let self = self else {
				  return
				}
				self.courierRoutingDelegate?.courierRouter(courierRouter: self,
														   courierArrivedAtDropoff: courier,
														   forRoute: route,
														   forOrderId: route.orderId)
			})
		}
	}
}
