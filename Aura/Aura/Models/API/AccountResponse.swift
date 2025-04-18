//
//  AccountResponse.swift
//  Aura
//
//  Created by Ordinateur elena on 21/03/2025.
//

import Foundation
struct AccountResponse: Codable, Equatable {
	let transactions: [Transaction]
	let currentBalance: Decimal
	
	//MARK: - Transaction
	struct Transaction: Codable, Equatable {
		let value: Decimal
		let label: String
	}
}
