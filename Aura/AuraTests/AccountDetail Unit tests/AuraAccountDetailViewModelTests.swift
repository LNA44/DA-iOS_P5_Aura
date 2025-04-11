//
//  AuraAllTransactionsViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAccountDetailViewModelTests: XCTestCase {
	
	var viewModel: AccountDetailViewModel!
	var dataMock = AuraAccountDetailMock()
	var repository: AuraRepository!
	let keychain = AuraKeychainService()
	
	override func setUp() {
		repository = AuraRepository( executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = AccountDetailViewModel(repository: repository)
		keychain.storeToken(token: "93D2C537-FA4A-448C-90A9-6058CF26DB29", key: "authToken")
		dataMock.response = 0
	}
	
	override func tearDown() {
		keychain.removeToken(key: "authToken")
	}
	
	func testFetchTransactionsSuccess() async {
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
