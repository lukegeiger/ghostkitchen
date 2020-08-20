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
	
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtPickup: Courier,
						   forRoute: Route,
						   forOrder: Order)
	
	func courierRouter(courierRouter: CourierRouting,
						   courierArrivedAtDropoff: Courier,
						   forRoute: Route,
						   forOrder: Order)
}

// MARK: CourierRouting

protocol CourierRouting {
	
	func commencePickupRoute(courier: Courier)
	func commenceDropoffRoute(courier: Courier)
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
