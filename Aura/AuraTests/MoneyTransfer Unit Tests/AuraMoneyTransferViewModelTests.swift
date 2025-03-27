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
	let keychain = AuraKeyChainServiceMock()
	
	override func setUpWithError() throws {
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = MoneyTransferViewModel(keychain: keychain, repository: repository)
		keychain.storeToken(token: "93D2C537-FA4A-448C-90A9-6058CF26DB29", key: "authToken")
	}
	
	override func tearDown() {
		keychain.removeToken(key: "authToken")
	}
	
	func testSendMoneySuccess() async {
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
		repository = AuraService(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = MoneyTransferViewModel(keychain: keychain, repository: repository)
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
