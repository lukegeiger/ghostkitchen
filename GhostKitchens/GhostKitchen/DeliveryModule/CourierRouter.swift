//
//  RouteSimulator.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: CourierRoutingDelegate

protocol CourierRoutingDelegate {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
        - forRoute: The handlebar of the bicycle
        - forOrder: The frame size of the bicycle, in centimeters
     */
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtPickup: Courier,
						   forRoute: Route,
						   forOrder: Order)
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierRouter: The style of the bicycle
        - courierArrivedAtPickup: The gearing of the bicycle
        - forRoute: The handlebar of the bicycle
        - forOrder: The frame size of the bicycle, in centimeters
     */

	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtDropoff: Courier,
						   forRoute: Route,
						   forOrder: Order)
}

// MARK: CourierRouting

protocol CourierRouting {
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courier: A courierDispatcher responsible for dispatching a courier to an order
     */
	func commencePickupRoute(courier: Courier)
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courier: A courierDispatcher responsible for dispatching a courier to an order
     */
	func commenceDropoffRoute(courier: Courier)
	
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.
     */
	var courierRoutingDelegate: CourierRoutingDelegate? { get set }
}

// MARK: CourierRouter

final class CourierRouter: CourierRouting {
	
	var courierRoutingDelegate: CourierRoutingDelegate?

	func commencePickupRoute(courier: Courier) {
		
		courier.schedule.routes.forEach { (route) in
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(route.timeToPickup), execute: {
				self.courierRoutingDelegate?.courierRouter(courierRouter: self,
																   courierArrivedAtPickup: courier,
																   forRoute:route,
																   forOrder: route.order)
			})
		}
	}
	
	func commenceDropoffRoute(courier: Courier) {
		
		courier.schedule.routes.forEach { (route) in
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(route.timeToDropoff), execute: {
				self.courierRoutingDelegate?.courierRouter(courierRouter: self,
														   courierArrivedAtDropoff: courier,
														   forRoute: route,
														   forOrder: route.order)
			})
		}
	}
}
