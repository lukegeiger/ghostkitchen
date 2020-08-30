//
//  Courier.swift
//  GhostKitchens
//
//  Created by Luke Geiger on 8/17/20.
//  Copyright © 2020 Luke Geiger. All rights reserved.
//

import Foundation

// MARK: Courier

struct Courier {
	
	let id: String /// Unique ID
	let schedule: Schedule
}

// MARK: Equatable

extension Courier: Equatable {
    static func == (lhs: Courier, rhs: Courier) -> Bool { return lhs.id == rhs.id}
}
