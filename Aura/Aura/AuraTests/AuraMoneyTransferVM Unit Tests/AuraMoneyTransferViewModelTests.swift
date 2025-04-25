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
		do {
		_ = try AuraKeychainService().saveToken(token: "token", key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
	}
	
	override func tearDown() {
		super.tearDown()
		do {
		_ = try AuraKeychainService().deleteToken(key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
	}
	
	func testSendMoneySuccess() async {
		//Given
		_ = mockData.makeMock(for: .success)
		
		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "")
	}
	
	func testSendMoneyItemNotFoundKeychainErrorOccurs() async {
		//Given
		do {
		_ = try keychain.deleteToken(key: Constante.MoneyTransfer.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
		_ = mockData.makeMock(for: .itemNotFoundKeychainError)
		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Item was not found")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testSendMoneyUnauthorizedAPIErrorOccurs() async {
		//Given
		do {
		_ = try keychain.deleteToken(key: Constante.MoneyTransfer.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
		_ = mockData.makeMock(for: .unauthorizedAPIError)
		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "You are not authorized to perform this action.")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testSeddMoneyUnknownErrorOccurs() async {
		//Given
		_ = mockData.makeMock(for: .unknownError)
		//When
		_ = await viewModel.sendMoney()
		//Then
		XCTAssertNotEqual(viewModel.errorMessage, "")
		XCTAssertTrue(viewModel.showAlert)
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
