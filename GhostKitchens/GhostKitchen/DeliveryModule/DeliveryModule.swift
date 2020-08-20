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
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrder:Order,
						onRoute:Route)
	
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrder: Order)
	
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier)
}

// MARK: DeliveryModule

final class DeliveryModule {
	
	var deliveryModuleDelegate: DeliveryModuleDelegate?
	var courierDispatcher: CourierDispatching
	var courierRouter: CourierRouting
	
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

