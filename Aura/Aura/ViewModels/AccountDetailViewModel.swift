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
	private let keychain: KeyChainServiceProtocol
	
	//MARK: -Initialisation
	init(keychain: KeyChainServiceProtocol, repository: AuraService) {
		self.keychain = keychain
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
			formatter.locale = Locale(identifier: "fr_FR")
			return formatter.string(from: number)
		}
	
	func formattedAmount(value: Decimal?) -> String {
			guard let unwrappedValue = value else {
				return "Invalid value"
			}
			
			let nsNumber = NSDecimalNumber(decimal: unwrappedValue)
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
		} catch {
			if let TransactionsError = error as? AuraService.fetchAccountDetailsError {
				switch TransactionsError {
				case .badURL :
					errorMessage = "URL invalide"
				case .missingToken :
					errorMessage = "Token manquant"
				case .noData :
					errorMessage = "Aucune donnée reçue"
				case .requestFailed :
					errorMessage = "Erreur de requête"
				case .serverError :
					errorMessage = "Erreur serveur"
				case .decodingError :
					errorMessage = "Erreur de décodage"
				}
				showAlert = true
			}
		}
	}
}
