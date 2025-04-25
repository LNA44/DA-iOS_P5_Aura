//
//  AuraAllTransactionsViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAccountDetailsViewModelTests: XCTestCase {
	let mockData = AuraAccountDetailsViewModelMock()
	
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
		do {
			super.setUp()
			_ = try keychain.saveToken(token: "token", key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
	}
	
	override func tearDown() {
		super.tearDown()
		do {
			_ = try keychain.deleteToken(key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
	}
	
	func testFetchTransactionsSuccess() async {
		//Given
		_ = mockData.makeMock(for: .success)
		//When
		await viewModel.fetchTransactions()
		//Then
		
		let expectedRecentTransactions: [(Decimal, String)] = [
			(-70.00, "Zara"),
			(-32.00, "SuperU"),
			(-10.00, "Starbucks")
		]
		
		let actualRecentTransactions = viewModel.recentTransactions.map { ($0.value, $0.label) }
		
		// Utilisation de zip pour combiner les deux collections puis les comparer
		for (expected, actual) in zip(expectedRecentTransactions, actualRecentTransactions) {
			XCTAssertEqual(expected.0, actual.0, "Les labels ne correspondent pas.") // Comparaison des labels
			XCTAssertEqual(expected.1, actual.1, "Les valeurs ne correspondent pas.") // Comparaison des valeurs
		}
		
		XCTAssertEqual(viewModel.totalAmount, Decimal(100))
		
		let expectedTotalTransactions: [(Decimal, String)] = [
			(-56.00,"IKEA"),
			(-10.00, "Starbucks"),
			(-32.00, "SuperU"),
			(-70.00, "Zara")
		]
		let actualTotalTransactions = viewModel.totalTransactions.map { ($0.value, $0.label) }
		
		// Utilisation de zip pour combiner les deux collections puis les comparer
		for (expected, actual) in zip(expectedTotalTransactions, actualTotalTransactions) {
			XCTAssertEqual(expected.0, actual.0, "Les labels ne correspondent pas.") // Comparaison des labels
			XCTAssertEqual(expected.1, actual.1, "Les valeurs ne correspondent pas.") // Comparaison des valeurs
		}
	}
	
	func testFetchAccountNoItemFoundKeychainErrorOccurs() async {
		//Given
		do {
		_ = try keychain.deleteToken(key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
		_ = mockData.makeMock(for: .noItemFoundKeychainError)
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Item was not found")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testFetchAccountNoDataAPIErrorOccurs() async {
		//Given
		_ = mockData.makeMock(for: .noDataAPIError)
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "No data received from the server.")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testFetchAccountUnkownErrorOccurs() async {
		//Given
		_ = mockData.makeMock(for: .unknownError)
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertNotEqual(viewModel.errorMessage, "")
		XCTAssertTrue(viewModel.showAlert)
	}
	
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

