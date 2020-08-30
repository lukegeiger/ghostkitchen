
# GhostKitchens Patch Notes


### 1. Retain Cycle Updates:

- Changed all delegates to be weak references
- Ensured self is not captured in closures

*Ex 1: Weak Delegates*

### Before

```
final class OrderCooker: OrderCooking  {
	
	var orderCookingDelegate: OrderCookingDelegate?
}
```

### After

```
final class OrderCooker: OrderCooking  {
	
	weak var orderCookingDelegate: OrderCookingDelegate?
}

```

*Ex 2: Capturing self in a closure*

### Before

```

receivedOrders.forEach { (order) in

}

```

### After

```
receivedOrders.forEach { [unowned self] (order) in

}
```

### 2. Data Model Updates: 

- I abstracted the decay property out from Order.swift which allowed me to turn it into a Struct from a class. Order decay is now tracked via a hash map on the OrderDecayMonitor. This also eliminated a possible concurrency issue updating decay in a non thread safe way.

- I reworked the concept of a Route into what is now a Task. A Task does not have a pick up and dropoff time like Route did. A task just has a duration, orderId, and a task type. In this case there are two task types, a pickup and a dropoff. An advantage to this is a courier may want to have 3 pickups, 1 dropoff, 2 pickups, then 4 dropoffs in that order for an optimized batched trip. This API makes that reality easier.  This is also a more natural way to bring in new things to instruct the courier to do. Lastly, Route had an Order property on it which I changed to just be an orderId string on the new Task object. I believe this is better so you do not have potentally conflicting instances of an Order.

*Ex 3: Route vs Task*

#### Before
```
struct Route {
	
	let order: Order
	let pickupDuration: Int
	let dropoffDuration: String
}
```

#### After
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

*Ex 4: Courier Schedule takes two Tasks instead of 1 Route*

### Before
```
let route = Task(order: order,
					  pickupDuration: Int.random(in: 2...6),
					  dropoffDuration: 0,
					  orderId: order.id)

let schedule = Schedule(scheduleId: UUID().uuidString,
						routes: [route])

let courier = Courier(id: UUID().uuidString,
					  schedule: schedule)
```

### After
```
let pickupTask = Task(type: .pickup,
					  duration: Int.random(in: 2...6),
					  orderId: order.id)

let dropoffTask = Task(type: .dropoff,
					   duration: 0,
					   orderId: order.id)

let schedule = Schedule(scheduleId: UUID().uuidString,
						tasks: [pickupTask,dropoffTask])

let courier = Courier(id: UUID().uuidString,
					  schedule: schedule)
```

### 3. Concurrency Updates:

- I abstracted out the Run Loop Start from the Simulation class onto main.m

- I turned Order.swift into a struct from a class, eliminating the decay property which was being updated in a non thread safe way. 

- Moved shelving, and removing, to property queues on ShelveOrderDistributor instead of an instance queue on every action they performed.

- Moved order decaying on OderDecayMonitor to a serial queue, as well as fixed a potential bug where decay would be updated based on incorrect oder and shelf information.

- Eliminated all uses of NSTimer in favor of DispatchSourceTimers.

- Moved the calls to dispatch couriers to pickup/dropoff, cook orders, route couriers, shelve orders,  to a background thread

- Fixed a bug where if an order took longer to cook than an instant, a courier would still pickup and deliver an order before it was able to get cooked & shelved. So now a courier waits indefinitely at a restaurant until a order gets shelved before they can pick it up and deliver it. This is represented as the following log

```
Courier: FAA414BF-0BBD-4420-AB08-D1F5D0E03893 waiting at restaurant for order 58e9b5fe-3fde-4a27-8e98-682e58a4a65d
```

Based on the directions this should never happen, however I think this check should for sure be in there.

*Ex 5: New Order Schema*

### Before
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

### After

```
struct Order: Decodable {

	let id: String /// Unique ID
	let name: String /// Name of the order
	let temp: ShelfTemperature /// Preferred shelf storage temperature
	let shelfLife: Int /// Shelf wait max duration (seconds)
	let decayRate: Float /// Value deterioration modifier
}
```

*Ex 6: Dispatching on background*

### Before
```
self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
```

### After

```
DispatchQueue.global(qos: .background).async { [unowned self] in
	self.deliveryModule.courierDispatcher.dispatchCouriers(forOrders: receivedOrders)
}
```

### 4. Additional Updates:

- Test coverage increased to 90.1%


