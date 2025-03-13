//
//  Model.swift
//  Aura
//
//  Created by Ordinateur elena on 10/03/2025.
//

import Foundation
//données API après parsing
struct AuthentificationData {
	let username: String
	let password: String
}
struct AccountResponse: Codable {
	let transactions: [Transaction]
	let currentBalance: Double
	
	//MARK: - Transaction
	struct Transaction: Codable {
		let value: Double
		let label: String
	}
}
