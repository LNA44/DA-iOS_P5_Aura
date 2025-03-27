//
//  AccountResponse.swift
//  Aura
//
//  Created by Ordinateur elena on 21/03/2025.
//

import Foundation
struct AccountResponse: Codable {
	let transactions: [Transaction]
	let currentBalance: Decimal
	
	//MARK: - Transaction
	struct Transaction: Codable {
		let value: Decimal
		let label: String
	}
}
