//
//  AuraMoneyTransferViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 15/03/2025.
//

import XCTest
@testable import Aura

final class AuraMoneyTransferViewModelTests: XCTestCase {
	var viewModel: MoneyTransferViewModel!
	var dataMock = DataMoneyTransferMock()
	var repository: AuraService!
	
    override func setUpWithError() throws {
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock)
		viewModel = MoneyTransferViewModel(repository: repository)
	AuraService.token = "93D2C537-FA4A-448C-90A9-6058CF26DB29"
	}

	func testSendMoneySuccess() async {
		//Given
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "100"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "")
	}
    
	func testSendMoneyFail() async {
		//Given
		dataMock.validResponse = false
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "20"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Les données devraient être vides")
	}

}
/*func sendMoney() async { //utilisée qd on clique sur bouton envoyer argent
	do {
		convertAmount(amountString: amountString)
		try await repository.sendTransfer(recipient: recipient, amount: amount)
		transferMessage = "Successfully transferred \(amount) to \(recipient)"
		recipient = "" //remise à 0 après transfert
		amountString = ""
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
 */
