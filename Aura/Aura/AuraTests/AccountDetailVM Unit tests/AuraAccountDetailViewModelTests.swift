//
//  AuraAllTransactionsViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAccountDetailViewModelTests: XCTestCase {
	
	let keychain = AuraKeychainService()
	
	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	lazy var repository = AccountRepository(keychain: keychain, APIService: apiService)
	
	lazy var viewModel = AccountDetailViewModel(repository: repository)

	
	override func setUp() {
		super.setUp()
		_ = AuraKeychainService().saveToken(token: "token", key: K.Account.tokenKey)
	}
	
	override func tearDown() {
		super.tearDown()
		_ = AuraKeychainService().deleteToken(key: K.Account.tokenKey)
	}
	
	func testFetchTransactionsSuccess() async {
		//Given
		let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account")!,
									   statusCode: 200,
									   httpVersion: nil,
									   headerFields: nil)!
		let jsonData = """
		{
			"currentBalance": 100,
			"transactions": [
				{
					"value": -56,
					"label": "IKEA"
				},
				{
					"value": -10,
					"label": "Starbucks"
					
				},
				{
					"value": -32,
					"label": "SuperU"
				},
				{
					"value": -70,
					"label": "Zara"
				}
			]
		}
		""".data(using: .utf8)!
		
		MockURLProtocol.requestHandler = { request in
			return (response, jsonData, nil) // Réponse simulée
		}
	
		//When
		_ = await viewModel.fetchTransactions()
		//Then
		let expectedRecentTransactions: [Transaction] = [
			Transaction(transaction: AccountResponse.Transaction(value: -70.00, label: "Zara")),
			Transaction(transaction: AccountResponse.Transaction(value: -32.00, label: "SuperU")),
			Transaction(transaction: AccountResponse.Transaction(value: -10.00, label: "Starbucks"))
			]
		
		XCTAssertEqual(viewModel.recentTransactions, expectedRecentTransactions)
		XCTAssertEqual(viewModel.totalAmount, Decimal(100))
		
		let expectedTotalTransactions: [Transaction] = [
			Transaction(transaction: AccountResponse.Transaction(value: -56.00, label: "IKEA")),
			Transaction(transaction: AccountResponse.Transaction(value: -10.00, label: "Starbucks")),
			Transaction(transaction: AccountResponse.Transaction(value: -70.00, label: "Zara")),
			Transaction(transaction: AccountResponse.Transaction(value: -32.00, label: "SuperU"))
			]
		
		XCTAssertEqual(viewModel.totalTransactions, expectedTotalTransactions)
		XCTAssertEqual(viewModel.errorMessage, "")
	}
	
	/*func testFetchTransactionsSuccess() async {
		//Given
		dataMock.response = 1
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "")
		XCTAssertEqual(viewModel.totalAmount, 12345.67)
		XCTAssertEqual(viewModel.totalTransactions.count, 5)
		XCTAssertEqual(viewModel.recentTransactions.count, 3)
	}
	
	func testFetchTransactionsBadURLErrorOccurs() async {
		//Given
		repository = AuraRepository(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = AccountDetailViewModel(repository: repository)
		dataMock.response = 2
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "URL invalide")
		XCTAssertEqual(viewModel.totalAmount, 0.00)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions.count, 0)
	}
	
	func testFetchTransactionsMissingTokenFail() async {
		//Given
		dataMock.response = 3
		keychain.removeToken(key: "authToken")
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Token manquant")
		XCTAssertEqual(viewModel.totalAmount, 0)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions, [])
	}
	
	func testFetchTransactionsNoDataErrorOccurs() async {
		//Given
		dataMock.response = 4
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Aucune donnée reçue")
		XCTAssertEqual(viewModel.totalAmount, 0)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions, [])
	}
	
	func testFetchTransactionsRequestFailedErrorOccurs() async {
		//Given
		dataMock.response = 5
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Erreur de requête")
		XCTAssertEqual(viewModel.totalAmount, 0)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions, [])
	}
	
	func testFetchTransactionsServerErrorOccurs() async {
		//Given
		dataMock.response = 6
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Erreur serveur")
		XCTAssertEqual(viewModel.totalAmount, 0)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions, [])
	}
	
	func testFetchTransactionsDecodingErrorOccurs() async {
		//Given
		dataMock.response = 7
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Erreur de décodage")
		XCTAssertEqual(viewModel.totalAmount, 0)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions, [])
	}
*/
	func testFormattedAmountSuccess() {
		//Given
		let value = Decimal(string: "12345.6789") //renvoie un optionnel
		//When
		let formattedValue = viewModel.formattedAmount(value: value)
		//Then
		XCTAssertEqual(formattedValue, "12\u{202F}345,68") //u{202F} = espace insécable automatiquement ajouté par la locale francaise entre les milliers
	}
	
	func testFormattedAmountFail() {
		let value: Decimal? = nil
		let formattedValue = viewModel.formattedAmount(value: value)
		XCTAssertEqual(formattedValue, "Invalid value")
	}
	
	func testErrorFormatting() {
		let value = Decimal(string: "12345.6789")
		viewModel.formatClosure = { _ in return nil } //closure prend un paramètre qui retourne nil
		let formatted = viewModel.formattedAmount(value: value)
		XCTAssertEqual(formatted, "Formatting error")
	}
}

