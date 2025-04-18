//
//  AuraMoneyTransferViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 15/03/2025.
//

import XCTest
@testable import Aura

final class AuraMoneyTransferViewModelTests: XCTestCase {
	let mockData = AuraMoneyTransferViewModelMock()
	let keychain = AuraKeychainService()
	
	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	lazy var repository = MoneyTransferRepository(keychain: keychain, APIService: apiService)
	
	lazy var viewModel = MoneyTransferViewModel(repository: repository)

	override func setUp() {
		super.setUp()
		_ = AuraKeychainService().saveToken(token: "token", key: K.Account.tokenKey)
	}
	
	override func tearDown() {
		super.tearDown()
		_ = AuraKeychainService().deleteToken(key: K.Account.tokenKey)
	}
	
	func testSendMoneySuccess() async {
		//Given
		_ = mockData.makeMock(for: .success)

		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "")
	}
	
	func testSendMoneyUnauthorizedAPIErrorOccurs() async {
		//Given
		_ = keychain.deleteToken(key: K.MoneyTransfer.tokenKey)
		
		_ = mockData.makeMock(for: .unauthorizedAPIError)
		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "You are not authorized to perform this action.")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testSendMoneyUnkownErrorOccurs() async {
		//Given
		_ = mockData.makeMock(for: .unknownError)
		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Une erreur inconnue est survenue : \(error.localizedDescription)")
		XCTAssertTrue(viewModel.showAlert)
	}
	
/*	func sendMoney() async { //utilisée qd on clique sur bouton envoyer argent
		do {
			convertAmount(amountString: amountString)
			try await repository.transferMoney(recipient: recipient, amount: amount)
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
*/
	/*func testSendMoneySuccess() async {
		//Given
		dataMock.response = 1
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "100"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "")
		XCTAssertEqual(viewModel.recipient, "")
		XCTAssertEqual(viewModel.amountString, "")
		XCTAssertEqual(viewModel.amount, Decimal(0.0))
	}
	
	func testSendMoneyBadURLFail() async {
		//Given
		repository = AuraRepository(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = MoneyTransferViewModel(repository: repository)
		dataMock.response = 2
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "20"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "URL invalide")
	}
	
	func testSendMoneyMissingTokenFail() async {
		//Given
		keychain.removeToken(key: "authToken")
		dataMock.response = 3
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "20"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Token manquant")
	}
	
	func testSendMoneyDataNotEmptyFail() async {
		//Given
		dataMock.response = 4
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "20"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Les données devraient être vides")
	}
	
	func testSendMoneyRequestFail() async {
		//Given
		dataMock.response = 5
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "20"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Erreur de requête")
	}
	
	func testSendMoneyServerFail() async {
		//Given
		dataMock.response = 6
		viewModel.recipient = "+33767070707"
		viewModel.amountString = "20"
		//When
		await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Erreur serveur")
	}
*/
	func testIsPhoneOrEmailValidWithPhoneSuccess() {
		//Given
		viewModel.recipient = "+33767070707"
		//When
		let isPhoneOrEmailValid = viewModel.isPhoneOrEmailValid()
		//Then
		XCTAssertTrue(isPhoneOrEmailValid)
	}
	
	func testIsPhoneOrEmailValidWithEmailSuccess() {
		//Given
		viewModel.recipient = "e@gmail.com"
		//When
		let isPhoneOrEmailValid = viewModel.isPhoneOrEmailValid()
		//Then
		XCTAssertTrue(isPhoneOrEmailValid)
	}
	
	func testIsPhoneOrEmailValidFail() {
		//Given
		viewModel.recipient = "+3307"
		//When
		let isPhoneOrEmailValid = viewModel.isPhoneOrEmailValid()
		//Then
		XCTAssertFalse(isPhoneOrEmailValid)
	}
	
	func testConvertAmountSuccess() {
		//Given
		viewModel.amountString = "100"
		//When
		viewModel.convertAmount(amountString: viewModel.amountString)
		//Then
		XCTAssertEqual(viewModel.amount, Decimal(100))
	}
	
	func testConvertAmountFail() {
		//Given
		viewModel.amountString = "abc"
		//When
		viewModel.convertAmount(amountString: viewModel.amountString)
		//Then
		XCTAssertEqual(viewModel.amount, Decimal(0.0))
	}
	
	func testIsAmountValidSuccess() {
		//Given
		viewModel.amountString = "100"
		//When
		let isAmountValid = viewModel.isAmountValid()
		//Then
		XCTAssertTrue(isAmountValid)
	}
	
	func testPhoneOrEmailPromptSuccess() {
		//Given
		viewModel.recipient = "+33767070707"
		//When
		let prompt = viewModel.phoneOrEmailPrompt
		//Then
		XCTAssertEqual(prompt, "")
	}
	
	func testPhoneOrEmailPromptFail() {
		//Given
		viewModel.recipient = "+337"
		//When
		let prompt = viewModel.phoneOrEmailPrompt
		//Then
		XCTAssertEqual(prompt, "Enter a valid phone number or email address")
	}
	
	func testamountPromptSuccess() {
		//Given
		viewModel.amountString = "100"
		//When
		let prompt = viewModel.amountPrompt
		//Then
		XCTAssertEqual(prompt, "")
	}
	
	func testamountPromptFail() {
		//Given
		viewModel.amountString = "0.00"
		//When
		let prompt = viewModel.amountPrompt
		//Then
		XCTAssertEqual(prompt, "Enter a valid amount with 2 decimals maximum")
	}
}

