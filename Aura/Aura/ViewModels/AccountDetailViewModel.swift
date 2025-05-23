//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
	//MARK: -Private properties
	private let repository: AccountRepository
	
	//MARK: -Initialisation
	init(repository: AccountRepository) {
		self.repository = repository
	}
	
	//MARK: -Outputs
	@Published var totalAmount: Decimal = 0.0
	@Published var totalTransactions: [Transaction] = []
	@Published var recentTransactions: [Transaction] = []
	@Published var errorMessage: String? = ""
	@Published var showAlert: Bool = false
	
	var formatClosure: (NSDecimalNumber) -> String? = { number in
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		formatter.locale = Locale(identifier: "fr_FR") //conventions régionales pour séparateur milliers et séparateur décimal
		return formatter.string(from: number)
	}
	
	func formattedAmount(value: Decimal?) -> String {
		guard let unwrappedValue = value else {
			return "Invalid value"
		}
		
		let nsNumber = NSDecimalNumber(decimal: unwrappedValue) //nécessaire pour NumberFormatter()
		guard let formattedValue = formatClosure(nsNumber) else {
			return "Formatting error"
		}
		return formattedValue
	}
	
	//MARK: -Inputs
	@MainActor
	func fetchTransactions() async {
		do {
			let (totalAmount,totalTransactions) = try await repository.fetchAccountDetails()
			self.totalAmount = totalAmount
			self.totalTransactions = totalTransactions
			let recentTransactions = Array(totalTransactions.reversed().prefix(3)) //récupère les 3 dernières transactions
			self.recentTransactions = recentTransactions
		} catch let error as AuraKeychainService.KeychainError {
			errorMessage = error.errorKeychainDescription
			showAlert = true
		} catch let error as APIError {
			errorMessage = error.errorDescription
			showAlert = true
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
	}
}
