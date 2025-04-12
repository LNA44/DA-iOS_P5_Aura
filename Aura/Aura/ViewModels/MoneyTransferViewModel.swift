//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
	//MARK: -Private properties
	private var repository: MoneyTransferRepository
	private var APIService = AuraAPIService()
	
	//MARK: -Initialisation
	init(repository: MoneyTransferRepository) {
		self.repository = repository
	}
	
	//MARK: -Outputs
	@Published var recipient: String = ""
	@Published var amount: Decimal = Decimal(0.0)
	@Published var transferMessage: String = ""
	@Published var errorMessage: String? = ""
	@Published var amountString: String = ""
	@Published var showAlert: Bool = false
	
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
	
	//MARK: -Inputs
	@MainActor
	func sendMoney() async { //utilisée qd on clique sur bouton envoyer argent
		do {
			convertAmount(amountString: amountString)
			try await repository.transferMoney(APIService: APIService,recipient: recipient, amount: amount)
			transferMessage = "Successfully transferred \(amount) to \(recipient)"
			recipient = "" //remise à 0 après transfert
			amountString = ""
			amount = Decimal(0.0)
			return
		} catch let error as APIError {
			errorMessage = error.errorDescription
			showAlert = true
		} catch {
			errorMessage = "Une erreur inconnue est survenue : \(error.localizedDescription)"
			showAlert = true
		}
	}
	
	func isPhoneOrEmailValid() -> Bool {
		// criterias here : http://regexlib.com
		let phoneRegex = "^(?:(?:\\+|00)33[\\s.-]{0,3}(?:\\(0\\)[\\s.-]{0,3})?|0)[1-9](?:[\\s.-]?\\d{2}){4}$"
		/*commence par +, 00 ou 0, puis 33
		séparateurs : espace, point ou tiret. De 0 à 3 séparateurs entre indicatif du pays et numéro
		numéro : premier chiffre: de 1 à 9, par groupe de 2 chiffres, avec 4 occurrences*/
		let emailRegex = "^([0-9a-zA-Z]([-.\\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\\w]*[0-9a-zA-Z])*\\.)+[a-zA-Z]{2,9})$"
		//idem que AuthenticationViewModel
		let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
		return phoneTest.evaluate(with: recipient) || emailTest.evaluate(with: recipient)
	}
	
	func isAmountValid() -> Bool {
		// criterias here : http://regexlib.com
		let amountTest = NSPredicate(format: "SELF MATCHES %@","^\\d+(?:\\.\\d{0,2})?$")
		//au moins un chiffre avant la virgule, un point, maximum 2 chiffres après le point
		return amountTest.evaluate(with: amountString)
	}
	
	func convertAmount(amountString: String) { //obligatoire car textField sort un string et pas un décimal
		if let decimalAmount = Decimal(string: amountString) {
			self.amount = decimalAmount
		} else {
			self.amount = Decimal(0.0)
		}
	}
}
