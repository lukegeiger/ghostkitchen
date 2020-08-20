# GhostKitchen

---

### 1. Running the Program

This a CLI program created on Mac running Mac OS Catalina Version 10.15.5, using Xcode version 11.6 in Swift. You can run the program two ways. The first way is  by opening the .xcworkspace file in the directory and click the play button in the upper left hand corner of Xcode. To see the output of the program open up the debugger of Xcode... The 2nd way is to navigate to the /bin directory and run the executable.

The **Simulation** class is responsible for containing the information needed to run the kitchen simulation. Orders from orders.json are parsed and placed into the simulation instance along with a configurable orders per second ingestion rate, and a GhostKitchen instance, which is explained in the sections below.

### 2. tl;dr Architecture Overview

The program is split into two main Modules the first is called **KitchenModule** and the 2nd is called  **DeliveryModule**.  **KitchenModule** is responsible for all things related to cooking, shelving, and monitoring decay  of orders.  **DeliveryModule** is responsible for all things related to dispatching couriers, routing them, and deliverying orders. 

The two modules are composed on what is called a  **GhostKitchen**. The idea behind this was that cooking, shelving, and monitoring order health, should really have no idea/care about creating delivery schedules, tracking order status, and delivering orders, and vice versa. Having said that, A **DeliveryModule** needs to know when to dispatch a courier, and a  **KitchenModule** needs to know when a order is going to be picked. The **GhostKitchen** handles these converstions between the modules by acting as a listener for significant events in the **KitchenModule** and **DeliveryModule**.

Here is an example of how that works

```
extension GhostKitchen: KitchenModuleDelegate {
	func kitchenModule(kitchenModule: KitchenModule,
				receivedOrders: [Order]) {
		self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
	}
}

```

Here, the **GhostKitchen** has a call back from the **KitchenModule** when it received orders. Once it receives orders, the **GhostKitchen** immeditaly tells the delivery modules dispatcher  to dispatch couriers to the order.

### 3. Models Deep Dive

The program has 5 model objects. Order, Courier, Schedule, Route, and Shelf. Order and Shelf were provided in the directions, so I will explain the 3 I created.

Courier, Schedule, and Route were created to model the delivery flow. A Courier gets dispatch to an Order. When a courier gets dispatched, a Schedule is created for them. A Schedule contains an array of Routes and each Route has an order attached to it. Each Route has a pick up time and drop off time. This modeling structure opens the door for an add on later where couriers can do batched pickups and dropoffs. 

### 4. KitchenModule Deep Dive

The KitchenModule is composed of an OrderCooker and a ShelveOrderDistributor. An order cooker is responsible for taking in orders to cook, and notifying the consumer when they are finished. A ShelveOrderDistributor is responsible for shelving orders in the best possible place, removing them when a courier picks up them, or when there is overflow, or when an order decays. 

The ShelveOrderDistributor is composed of a OrderDecayMonitor that simply monitors the orders on its shelves and notifies the ShelveOrderDistributor when a order has gone bad. See Order Decay Extra Credit for more information.

These two modules communicate with each other by being composed on the KitchenModule which listens to significant events from the Distributor and the Cooker.

### 5. DeliveryModule Deep Dive

The DeliveryModule is composed of a CourierRouter and a CourierDispatcher. A CourierDispatcher is responsible for dispatching a courier to pick up an Order. It does this by creating a Schedule for them to follow. Please see Models Deep Dive for how a schedule works. A Courier Router is responsible for routing a courier to a pickup and dropoff. These two modules communicate with each other by being composed on the DeliveryModule which listens to significant events from the Dispatcher and the Router.

### 6. Order Decay Extra Credit

Order Decay Logic is encapsulated inside the OrderDecayMonitor. The OrderDecayMonitors job is to essentially monitor its datasources shelves(which contain orders) for decayed orders, then notifying its delegate when it finds one. It does not perform any removals of the orders itself. It simply is just a monitor and tells whoever its delegate is that an order decayed and does not care what its delegate does when that happens. I composed the OrderDecayMonitor on the ShelveOrderDistributor.

Here is a look at the decay monitors datasource and delegate.

```
// MARK: OrderDecayMonitorDelegate

protocol OrderDecayMonitorDelegate {
	
    /**
     A delegate callback that lets the consumer know when an order has decayed.

     - Parameters:
        - monitor: The monitor that detected the decay
        - detectedDecayedOrder: The decayed order
     */
	func orderDecayMonitor(monitor: OrderDecayMonitor,
						   detectedDecayedOrder: Order)
	
    /**
     A delegate callback that lets the consumer know when the decay for an order has been updated

     - Parameters:
        - monitor: The monitor that detected the decay
		- updatedDecay: The decay amount
        - forOrder: The decaying order
     */
	func orderDecayMonitor(monitor: OrderDecayMonitor,
						   updatedDecay: Float,
						   forOrder: Order)
}

// MARK: OrderDecayMonitorDataSource

protocol OrderDecayMonitorDataSource {
	
    /**
     The shelves that the OrderDecayMonitor will monitor for decay.
     */
	func monitoringShelves() -> [Shelf]
}
```

An orders decay will be nil until set the order decay gets updated by the callback from OrderDecayMonitor in the ShelveOrderDistributor.

### 7. Testing Suite

Tests can be found under GhostKitchenTests. 

### 8. FAQ

- How do I change the ingestion rate?
      You can change the ingestion rate by going into main.swift and change the ingestion parameter on the simulation.
      
- How can I change the simulation orders json?
	If you are running the program from Xcode You can modify the json by simply opening the orders.json file in the project and modifying it to however you please.. If you are running from the command line, modify the orders.json file in the /bin
      
