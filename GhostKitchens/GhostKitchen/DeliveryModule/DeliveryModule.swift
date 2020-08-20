//
//  DeliveryModule.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/18/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: DeliveryModuleDelegate

protocol DeliveryModuleDelegate {
	
    /**
		A delegate callback that lets a consumer know whhen a courier arrived for an order

     - Parameters:
        - deliveryModule: The delivery module that performed the action
        - courier: The courier who arrived
        - arrivedForOrder: The order arrivng for
        - onRoute: The route the courier was on
     */
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrder:Order,
						onRoute:Route)
	
    /**
     A delegate callback that lets a consumer know when an order was delivered

     - Parameters:
        - deliveryModule: The delivery module that performed the action
        - courier: The courier who delivered the order
        - deliveredOrder: The delivered order
     */
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrder: Order)
	
    /**
		A callback that lets a consumer know when a courier got routed to an order

     - Parameters:
        - deliveryModule: The delivery module that performed the action
        - routed: The courier who got routed
     */
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier)
}

// MARK: DeliveryModule

final class DeliveryModule {
	
	private var courierRouter: CourierRouting

	var deliveryModuleDelegate: DeliveryModuleDelegate?
	var courierDispatcher: CourierDispatching
		
    /**
     Initializes a new DeliveryModule that is responsible for  all things related to dispatching a courier to pick up an order, and tracking their status throughout their route.

     - Parameters:
        - courierDispatcher: A courierDispatcher responsible for dispatching a courier to an order
        - courierRouter: a courierRouter responsivle for knowing when a courier arrives at a pickup and dropoff

     - Returns: A delivery system ready to deliver all the orders!
     */
	init(courierDispatcher: CourierDispatching,
		 courierRouter: CourierRouting) {
		self.courierDispatcher = courierDispatcher
		self.courierRouter = courierRouter
		self.courierRouter.courierRoutingDelegate = self
		self.courierDispatcher.courierDispatchDelegate = self
	}
}

// MARK: CourierDispatchDelegate

extension DeliveryModule: CourierDispatchDelegate {
	
	func courierDispatcher(courierDispatcher: CourierDispatching,
						   routedCourier: Courier) {
		
		self.courierRouter.commencePickupRoute(courier: routedCourier)
		self.deliveryModuleDelegate?.deliveryModule(deliveryModule: self,
													routed: routedCourier)
	}
}

// MARK: CourierRoutingDelegate

extension DeliveryModule: CourierRoutingDelegate {
	
	func courierRouter(courierRouter: CourierRouting,
					   courierArrivedAtPickup: Courier,
					   forRoute: Route,
					   forOrder: Order) {
		
		self.courierRouter.commenceDropoffRoute(courier: courierArrivedAtPickup)
		self.deliveryModuleDelegate?.deliveryModule(deliveryModule: self,
													courier: courierArrivedAtPickup,
													arrivedForOrder: forOrder,
													onRoute: forRoute)
	}
	
	func courierRouter(courierRouter: CourierRouting,
					   courierArrivedAtDropoff: Courier,
					   forRoute: Route,
					   forOrder: Order) {
		
		self.deliveryModuleDelegate?.deliveryModule(deliveryModule: self,
													courier: courierArrivedAtDropoff,
													deliveredOrder: forOrder)
	}
}

