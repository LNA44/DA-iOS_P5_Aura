//
//  AnnTransactionsViewModel.swift
//  Aura
//
//  Created by Ordinateur elena on 13/03/2025.
//

import Foundation
class AllTransactionsViewModel: ObservableObject {
	@Published var totalAmount: Double = 0.0
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
	
	func formattedAmount(value: Double) -> String { //pour éviter les 0 inutiles à l'affichage
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.minimumFractionDigits = 0
			formatter.maximumFractionDigits = 2
			
			if let formattedValue = formatter.string(from: NSNumber(value: value)) {
				return formattedValue
			}
			return "N/A"  // Valeur par défaut si la transformation échoue
		}
}
