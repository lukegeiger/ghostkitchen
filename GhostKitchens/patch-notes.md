
GhostKitchens Patch Notes


1. Retain Cycles: There were two main common themes I missed. Not setting weak delegates, and capturing self in closures. 

Ex 1: Weak Delegates

Before

```
final class OrderCooker: OrderCooking  {
	
	var orderCookingDelegate: OrderCookingDelegate?
}
```

After

```
final class OrderCooker: OrderCooking  {
	
	weak var orderCookingDelegate: OrderCookingDelegate?
}

```

Ex 2: Capturing self in a closure

Before

```

receivedOrders.forEach { (order) in

}

```

After

```
receivedOrders.forEach { [unowned self] (order) in

}
```

2. Data Model Updates: 

- I abstracted the "decay" property out from Order.swift which allowed me to turn it into a Struct. Order decay is now tracked via a hash map on the OrderDecayMonitor. This also eliminated a possible concurrency issue.

- I reworked the concept of a Route into what is now a Task. A Task does not have a pick up and dropoff time like route did. A task just has a duration, orderId, and a task type. In this case there are two task types, a pickup and a dropoff. An advantage to this is a courier may want to have 3 pickups, 1 dropoff, 2 pickups, then 4 dropoffs in that order for an optimized batched trip. I believe this is also a more natural way to bring in new things to instruct the courier to do. Lastly, Route.swift had a Order property on it which I changed to just  be a orderId string on the new Task object. I believe this is better so you do not have two possible mismatching orders with different information on them floating around

Ex 3: Route vs Shelf

Before
```
struct Route {
	
	let order: Order
	let pickupDuration: Int
	let dropoffDuration: String
}
```

After
```
enum TaskType {
	
	case pickup
	case dropoff
}

struct Task {
	
	let type: TaskType
	let duration: Int
	let orderId: String
}
```

3. Concurrency Updates:

- I abstracted out the Run Loop Start from the Simulation class onto main.m

- I turned Order.swift into a struct from a class, while eliminating the decay property which was being updated in a non thread safe way. 

- Moved shelving, and removing, to property queues on ShelveOrderDistributor instead of an instance queue on every action they performed.

- Moved order decaying on OderDecayMonitor to a serial queue, as well as fixed a potential bug where decay would be updated based on incorrect oder and shelf information.

- Eliminated all use of NSTimer in favor of DispatchSource timers.

- Moved the calls to dispatch couriers to pickup/dropoff, cook orders, route couriers, shelve orders,  to a background thread

Ex 4: New Order Schema

Before
```
class Order: Decodable {

	let id: String /// Unique ID
	let name: String /// Name of the order
	let temp: ShelfTemperature /// Preferred shelf storage temperature
	let shelfLife: Int /// Shelf wait max duration (seconds)
	let decayRate: Float /// Value deterioration modifier
	var decay: Float
}
```

After

```
struct Order: Decodable {

	let id: String /// Unique ID
	let name: String /// Name of the order
	let temp: ShelfTemperature /// Preferred shelf storage temperature
	let shelfLife: Int /// Shelf wait max duration (seconds)
	let decayRate: Float /// Value deterioration modifier
}
```

Ex 5: Dispatching on background

Before
```
self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
```

After

```
DispatchQueue.global(qos: .background).async { [unowned self] in
	self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
}
```


4. Additional Updates:

- Test coverage increased to 94.4%


