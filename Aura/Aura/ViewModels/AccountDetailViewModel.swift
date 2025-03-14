//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
	@Published var totalAmount: Decimal = 0.0
	@Published var totalTransactions: [Transaction] = []
    @Published var recentTransactions: [Transaction] = []
	@Published var isLoading: Bool = false
	@Published var networkError: String? = nil
	private let repository: AuraService
	
	init(repository: AuraService = AuraService()) {
		self.repository = repository
	}
	@MainActor
	func fetchTransactions() async {
		guard AuraService.token != nil else {
			print("Le token est invalide ou absent.")
			return
		}
		isLoading = true
		do {
			let (totalAmount,totalTransactions) = try await AuraService().fetchAccountDetails()
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
	
	func formattedAmount(value: Decimal) -> String { //pour éviter les 0 inutiles à l'affichage
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.minimumFractionDigits = 0
			formatter.maximumFractionDigits = 2
			
		// Convertir le Decimal en NSNumber
			let nsNumber = NSDecimalNumber(decimal: value)
		
			if let formattedValue = formatter.string(from: nsNumber) {
				return formattedValue
			}
			return "N/A"  // Valeur par défaut si la transformation échoue
		}
}
