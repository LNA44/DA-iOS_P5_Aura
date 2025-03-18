//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
	//MARK: -Properties
	private var repository: AuraService
	@Published var recipient: String = ""
	@Published var amount: Decimal = Decimal(0.0)
    @Published var transferMessage: String = ""
	@Published var errorMessage: String? = ""
	@Published var amountString: String = ""
   
	//MARK: -Initialisation
	init(repository: AuraService) {
		self.repository = repository
	}
	
	//MARK: -Validation functions
   @MainActor
	func sendMoney() async { //utilisée qd on clique sur bouton envoyer argent
		do {
			convertAmount(amountString: amountString)
			try await repository.sendTransfer(recipient: recipient, amount: amount)
			transferMessage = "Successfully transferred \(amount) to \(recipient)"
			recipient = "" //remise à 0 après transfert
			amountString = ""
			amount = Decimal(0.0)
			return
		} catch {
			if let TransferError = error as? AuraService.TransferError {
				switch TransferError {
				case .badURL :
					errorMessage = "URL invalide"
				case .dataNotEmpty :
					errorMessage = "Les données devraient être vides"
				case .requestFailed :
					errorMessage = "Erreur de requête"
				case .encodingError :
					errorMessage = "Erreur d'encodage"
				case .serverError :
					errorMessage = "Erreur serveur"
				}
				transferMessage = "Please enter recipient and amount."
				print("Erreur inconnue : \(error.localizedDescription)")
			}
		}
    }
	
	func isPhoneOrEmailValid() -> Bool {
		// criterias here : http://regexlib.com
		let phoneRegex = "^(?:(?:\\+|00)33[\\s.-]{0,3}(?:\\(0\\)[\\s.-]{0,3})?|0)[1-9](?:[\\s.-]?\\d{2}){4}$"
		let emailRegex = "^([0-9a-zA-Z]([-.\\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\\w]*[0-9a-zA-Z])*\\.)+[a-zA-Z]{2,9})$"
		let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)		//self matches pr utliser des regex
		return phoneTest.evaluate(with: recipient) || emailTest.evaluate(with: recipient)
	}
	
	func isAmountValid() -> Bool {
		// criterias here : http://regexlib.com
		let amountTest = NSPredicate(format: "SELF MATCHES %@","^\\d+(?:\\.\\d{0,2})?$") //self matches pr utliser des regex
		return amountTest.evaluate(with: amountString)
	}
	//MARK: -Validation prompt strings
	
	var phoneOrEmailPrompt: String {
		if !isPhoneOrEmailValid() {
			return "Enter a valid phone number or email address"
		}
		return ""
	}
	
	var amountPrompt: String {
		if amountString == "0.00" || !isAmountValid() {
			return "Enter a valid amount with 2 decimals maximum"
		}
		return ""
	}
	
	func convertAmount(amountString: String) {
		if let decimalAmount = Decimal(string: amountString) {
			self.amount = decimalAmount
		} else {
			self.amount = Decimal(0.0)
		}
	}
}
