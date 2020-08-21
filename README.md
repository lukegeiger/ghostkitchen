# GhostKitchen

---

### 1. Running the Program

This a CLI program created on Mac running Mac OS Catalina Version 10.15.5, using Xcode version 11.6 in Swift. You can run the program two ways. The first way is  by opening the .xcworkspace file in the directory and click the play button in the upper left hand corner of Xcode. To see the output of the program open up the debugger of Xcode. The 2nd way is to navigate to the /bin directory and run the executable.

The **Simulation** class is responsible for containing the information needed to run the kitchen simulation. Orders from orders.json are parsed and placed into the simulation instance along with a configurable orders per second ingestion rate, and a GhostKitchen instance, which is explained in the sections below.

Please note if you are running from the CLI, you need to rebuild the program in Xcode whenever you make any changes.

### 2. Architecture Overview

The program is split into two main Modules the first is called **KitchenModule** and the 2nd is called  **DeliveryModule**. **KitchenModule** is responsible for all things related to cooking, shelving, and monitoring decay  of orders. **DeliveryModule** is responsible for all things related to dispatching couriers, routing them, and delivering orders. 

The two modules are composed on what is called a **GhostKitchen**. The idea behind this was cooking, shelving, and monitoring order health, should have no idea/care about creating delivery schedules, tracking order status, and delivering orders, and vice versa. Having said that, A **DeliveryModule** needs to know when to dispatch a courier, and a  **KitchenModule** needs to know when an order is going to be picked up. The **GhostKitchen** handles these conversations between the modules by acting as a listener for significant events in the **KitchenModule** and **DeliveryModule**.

Here is an example of how that works

```
extension GhostKitchen: KitchenModuleDelegate {
	func kitchenModule(kitchenModule: KitchenModule,
				receivedOrders: [Order]) {
		self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
	}
}

```

Here, the **GhostKitchen** has a callback from the **KitchenModule** when it received orders. Once it receives orders, the **GhostKitchen** immediately tells the **DeliveryModules** dispatcher to dispatch couriers to pickup the order.

Currently, the **KitchenModule** has these callbacks that the **GhostKitchen** listens for.

```
protocol KitchenModuleDelegate {
	func kitchenModule(kitchenModule: KitchenModule,
				 receivedOrders: [Order])
	
	func kitchenModule(kitchenModule: KitchenModule,
						cooked: [Order])
	
  	func kitchenModule(kitchenModule: KitchenModule,
							removed: Order,
							fromShelf: Shelf,
							reason: ShelveOrderDistributorRemovalReason)
}
```

The **DeliveryModules** has these callbacks that the **GhostKitchen** listens for.

```
protocol DeliveryModuleDelegate {
	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						arrivedForOrder:Order,
						onRoute:Route)

	func deliveryModule(deliveryModule: DeliveryModule,
						courier: Courier,
						deliveredOrder: Order)
	
	func deliveryModule(deliveryModule: DeliveryModule,
						routed: Courier,
						forOrder: Order)
}
```

Logging takes place when an order is _received_, _cooked_, _shelved_, _courier routed_, _order removed (for either pickup, overflow, or decay)_, _courier arrived_, and _courier dropoff_.

Shelve contents are printed when an order is _received_, _shelved_, _removed (for any reason)_, and when an order is _delivered_. I chose not to print shelve contents on _courier routed_, and _courier arrived_, due to the verbosity of printing since when a courier is routed the order is cooked at the same time which prints the shelves, then when a courier arrived the contents get printed when an order is removed which is instant for the sake of this simualation.

### 3. Models Deep Dive

The program has 5 model objects. **Order**, **Courier**, **Schedule**, **Route**, and **Shelf**. **Order** and **Shelf** were provided in the directions, so I will explain the 3 I created.

**Courier**, **Schedule**, and **Route** were created to model the delivery flow. A **Courier** gets dispatch to an **Order**. When a **Courier** gets dispatched, a **Schedule** is created for them. A **Schedule** contains an array of **Routes** and each **Route** has an **Order** attached to it. Each **Route** has a pick up time and drop off time. This modeling structure opens the door for an add on later where couriers can do batched pickups and dropoffs.

### 4. KitchenModule Deep Dive

The **KitchenModule** is composed of an **OrderCooker** and a **ShelveOrderDistributor**. An **OrderCooker** is responsible for taking in orders to cook, and notifying the consumer when they are finished. A **ShelveOrderDistributor** is responsible for shelving orders in the best possible place, removing them when a courier picks up them, removing them when there is overflow, or removing them when an order decays. 

The **ShelveOrderDistributor** is composed of an **OrderDecayMonitor** that monitors the orders on its parents shelves and notifies the parent (in this case the **ShelveOrderDistributor**) when an order has gone bad. See Order Decay Extra Credit for more information.

These two modules communicate with each other by being composed on the **KitchenModule** which listens to significant events from the **ShelveOrderDistributor** and the **OrderCooker**.

### 5. DeliveryModule Deep Dive

The **DeliveryModule** is composed of a **CourierRouter** and a **CourierDispatcher**. A **CourierDispatcher** is responsible for dispatching a courier to pick up an **Order**. It does this by creating a **Schedule** for them to follow. 

Please see Models Deep Dive for how a **Schedule** works. A **CourierRouter** is responsible for routing a courier to a pickup and dropoff. These two modules communicate with each other by being composed on the **DeliveryModule** which listens to significant events from the **CourierDispatcher** and the **CourierRouter**.

### 6. Order Decay Extra Credit

Order Decay Logic is encapsulated inside the **OrderDecayMonitor**. The **OrderDecayMonitors** job is to essentially monitor its parents shelves for decayed orders. If it detects a decayed order, it notifiys its delegate. **It does not perform any removals of the orders itself**. It is just a monitor and tells whoever its delegate is that an order decayed and does not care what its delegate does when that happens. I composed the **OrderDecayMonitor** on the **ShelveOrderDistributor**.

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
As you can see from the **OrderDecayMonitorDataSource** it monitors its datasources shelves, so whenever its datasource removes an object from its shelves, the monitor will automatically be updated.

An orders decay will be nil until set the order decay gets updated by the callback from **OrderDecayMonitor** in the **ShelveOrderDistributor**. Decaying starts happening a second after an item is placed on a shelf, so note that while looking at logs.

### 7. Testing Suite

Tests can be found under GhostKitchenTests. CMD + U is a shortcut for running tests. Current Coverage is at **87.1%** the remaining things not covered by tests are files like main.swift that just start the program, and things like logging taking place in function callbacks

### 8. FAQ

- How do I change the ingestion rate?
      You can change the ingestion rate by going into main.swift and change the ingestion parameter on the simulation.
      
- How can I change the simulation orders json?
	If you are running the program from Xcode You can modify the json by simply opening the orders.json file in the project and modifying it to however you please.. If you are running from the command line, modify the orders.json file in the /bin
      
