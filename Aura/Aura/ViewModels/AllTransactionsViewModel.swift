//
//  AnnTransactionsViewModel.swift
//  Aura
//
//  Created by Ordinateur elena on 13/03/2025.
//

import Foundation
class AllTransactionsViewModel: ObservableObject {
	//MARK: -Private properties
	private let repository: AuraRepository
	private var APIService = AuraAPIService()
	
	//MARK: -Initialisation
	init(repository: AuraRepository) {
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
			let (totalAmount,totalTransactions) = try await repository.fetchAccountDetails(APIService: APIService)
			self.totalAmount = totalAmount
			self.totalTransactions = totalTransactions
		} catch let error as APIError {
			errorMessage = error.errorDescription
			showAlert = true
		} catch {
			errorMessage = "Une erreur inconnue est survenue : \(error.localizedDescription)"
			showAlert = true
		}
	}
}
