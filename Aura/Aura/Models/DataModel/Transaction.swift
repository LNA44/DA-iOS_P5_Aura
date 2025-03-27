//
//  Transaction.swift
//  Aura
//
//  Created by Ordinateur elena on 12/03/2025.
//

import Foundation
//modèle interne à l'app
struct Transaction: Identifiable, Equatable {
	var id = UUID() //utile pour ForEach
	let value: Decimal
	let label: String
	
	//MARK: - Init
	init(transaction: AccountResponse.Transaction) {
		self.value = transaction.value
		self.label = transaction.label
	}
}
