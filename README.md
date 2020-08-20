# GhostKitchen

---

### 1. Running the Program

This a CLI program created on Mac running Mac OS Catalina Version 10.15.5, using Xcode version 11.6 in Swift. You can run the program by simply opening the .xcworkspace file in the directory and click the play button in the upper left hand corner of Xcode. To see the output of the program open up the debugger of Xcode.

### 2. tl;dr Architecture Overview

The program is split into two main Modules the first is called KitchenModule and the 2nd is called DeliveryModule. KitchenModule is responsible for all things related to cooking, shelving, and monitoring decay health of orders. DeliveryModule is responsible for all things related to dispatching couriers to pickup orders, routing them, and deliverying them. 

The two modules are composed on what I called a GhostKitchen. The idea behind this was that cooking, shelving, and monitoring order health, should really have no idea/care about creating delivery schedules, tracking order status, and delivering orders, and vice versa. Having said that, A DeliveryModule needs to know when to dispatch a courier, and a KitchenModule needs to know when a order is going to be picked. The GhostKitchen handles these converstions between the modules by  acting as a listener for significant events in the KitchenModule and DeliveryModule.

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

Order Decay Logic is encapsulated inside the OrderDecayMonitor. The OrderDecayMonitors job is to essentially just monitor its datasources shelves(which contain orders) for decayed orders, then notifying its delegate when it finds one. It does not perform any removals of the orders itself. It simply is just a monitor and tells whoever its delegate is that an order decayed and does not care what its delegate does when that happens. I composed the OrderDecayMonitor into the ShelveOrderDistributor.

Here is a look at the decay monitors datasource and delegate.

```
// MARK: OrderDecayMonitorDataSource

protocol OrderDecayMonitorDataSource {
	
    /**
     The shelves that the OrderDecayMonitor will monitor for decay.
     */
	func monitoringShelves() -> [Shelf]
}

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
}

```

### 7. Testing Suite
Tests can be found under GhostKitchenTests.

### 8. FAQ

- How do I change the ingestion rate?
      You can change the ingestion rate by going into main.swift and change the ingestion parameter on the simulation.
      
- How can I change the simulation orders json?
      You can modify the json by simply opening the orders.json file in the project and modifying it to however you please.
      



### Sample Output 

```
Order: Banana Split a8cfcb76-7f24-4420-a5ba-d46dd77bdffd Received

Hot Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Cold Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Frozen Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Overflow Shelf
Capacity: 15
Order Count: 0
Shelf Decay Modifier: 2
Orders:  []
________________________________

Shelved: Banana Split a8cfcb76-7f24-4420-a5ba-d46dd77bdffd on Frozen Shelf

Hot Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Cold Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Frozen Shelf
Capacity: 10
Order Count: 1
Shelf Decay Modifier: 1
Orders:  [GhostKitchens.Order(id: "a8cfcb76-7f24-4420-a5ba-d46dd77bdffd", name: "Banana Split", temp: GhostKitchens.ShelfTemperature.frozen, shelfLife: 20, decayRate: 0.63)]
________________________________
Overflow Shelf
Capacity: 15
Order Count: 0
Shelf Decay Modifier: 2
Orders:  []
________________________________

Courier: 0BF5FAE2-CF9C-4D85-B2D9-49885EF5331B picking up order Banana Split a8cfcb76-7f24-4420-a5ba-d46dd77bdffd
Order: a8cfcb76-7f24-4420-a5ba-d46dd77bdffd removed from Frozen Shelf

Hot Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Cold Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Frozen Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Overflow Shelf
Capacity: 15
Order Count: 0
Shelf Decay Modifier: 2
Orders:  []
________________________________

Courier: 0BF5FAE2-CF9C-4D85-B2D9-49885EF5331B dropped off order Banana Split a8cfcb76-7f24-4420-a5ba-d46dd77bdffd

Hot Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Cold Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Frozen Shelf
Capacity: 10
Order Count: 0
Shelf Decay Modifier: 1
Orders:  []
________________________________
Overflow Shelf
Capacity: 15
Order Count: 0
Shelf Decay Modifier: 2
Orders:  []
________________________________

```
