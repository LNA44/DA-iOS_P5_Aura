//
//  AnnTransactionsViewModel.swift
//  Aura
//
//  Created by Ordinateur elena on 13/03/2025.
//

import Foundation
class AllTransactionsViewModel: ObservableObject {
	//MARK: -Private properties
	private let repository: AuraService
	
	//MARK: -Initialisation
	init(repository: AuraService) {
		self.repository = repository
	}
	
	//MARK: -Outputs
	@Published var totalAmount: Decimal = 0.0
	@Published var totalTransactions: [Transaction] = []
	@Published var errorMessage: String? = ""
	@Published var showAlert: Bool = false
	
	func formattedAmount(value: Decimal?) -> String { //pour éviter les 0 inutiles à l'affichage
		guard let unwrappedValue = value else {
			return "Invalid value"
		}
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		formatter.locale = Locale(identifier: "fr_FR") //conventions régionales pour séparateur milliers et séparateur décimal 
		
		// Convertir le Decimal en NSNumber
		let nsNumber = NSDecimalNumber(decimal: unwrappedValue)
		let formattedValue = formatter.string(from: nsNumber) ?? "N/A" //retourne un optionnel
		return formattedValue
	}
	
	//MARK: -Inputs
	@MainActor
	func fetchTransactions() async {
		do {
			let (totalAmount,totalTransactions) = try await repository.fetchAccountDetails()
			self.totalAmount = totalAmount
			self.totalTransactions = totalTransactions
		} catch {
			if let TransactionsError = error as? AuraService.FetchAccountDetailsError {
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
