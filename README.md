# GhostKitchen

---

### 1. Running the Program

### 2. tl;dr Architecture Overview

The program is split into two main Modules the first is called KitchenModule and the 2nd is called DeliveryModule. KitchenModule is responsible for all things related to cooking, shelving, and monitoring decay health of orders. DeliveryModule is responsible for all things related to dispatching couriers to pickup orders, routing them, and deliverying them. 

The two modules are composed on what I called a GhostKitchen. The idea behind this was that cooking, shelving, and monitoring, order health should really have no idea/care about creating delivery schedules, tracking order status, and vice versa. Having said that though, they do need to be notified when an order is recieved, and when and order is ready to be picked up. The GhostKitchen handles these converstions between the modules by basically acting as a listener for significant events in the KitchenModule and DeliveryModule.


### 3. Models Deep Dive

### 4. Kitchen Module Deep Dive

### 5. Delivery Module Deep Dive

### 6. Things That Could be Improved

### 7. Testing Suite

### 8. FAQ
