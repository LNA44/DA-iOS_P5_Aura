//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
	//MARK: -Private properties
	private let repository: AuraService
	
	//MARK: -Initialisation
	init(repository: AuraService) {
		self.repository = repository
	}
	
	//MARK: -Outputs
	@Published var totalAmount: Decimal = 0.0
	@Published var totalTransactions: [Transaction] = []
	@Published var recentTransactions: [Transaction] = []
	@Published var isLoading: Bool = false
	@Published var networkError: String? = nil
	
	func formattedAmount(value: Decimal) -> String { //pour éviter les 0 inutiles à l'affichage
		let formatter = NumberFormatter() //formater les nombres selon convention locale
		formatter.numberStyle = .decimal //format nombre décimal
		formatter.minimumFractionDigits = 0 // pas de décimales affichées si partie décimale nulle
		formatter.maximumFractionDigits = 2 // max 2 décimales affichées
		
		// Convertir le Decimal en NSNumber
		let nsNumber = NSDecimalNumber(decimal: value) //conversion en NSNumber (nécessaire pour NumberFormatter)
		
		if let formattedValue = formatter.string(from: nsNumber) { //conversion en String
			return formattedValue
		}
		return "N/A"  // Valeur par défaut si la transformation échoue
	}
	
	//MARK: -Inputs
	@MainActor
	func fetchTransactions() async {
		guard AuraService.token != nil else {
			print("Le token est invalide ou absent.")
			return
		}
		isLoading = true
		do {
			let (totalAmount,totalTransactions) = try await repository.fetchAccountDetails()
			self.totalAmount = totalAmount
			self.totalTransactions = totalTransactions
			self.isLoading = false
			let recentTransactions = Array(totalTransactions.reversed().prefix(3)) //récupère les 3 dernières transactions
			self.recentTransactions = recentTransactions
		} catch {
			self.isLoading = false
			self.networkError = "Error fetching transactions: \(error.localizedDescription)"
			print(self.networkError ?? "No error")
		}
	}
}
