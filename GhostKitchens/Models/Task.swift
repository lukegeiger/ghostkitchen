//
//  Task.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/27/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

enum TaskType {
	
	case pickup
	case dropoff
}

struct Task {
	
	let type: TaskType
	let duration: Int
	let orderId: String
}
