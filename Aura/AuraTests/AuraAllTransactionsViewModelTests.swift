//
//  AuraAllTransactionsViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAllTransactionsViewModelTests: XCTestCase {
	
	var viewModel: AllTransactionsViewModel!
	var dataMock = DataAllTransactionsMock()
	var repository: AuraService!
	
	override func setUp() {
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock)
		viewModel = AllTransactionsViewModel(repository: repository)
		AuraService.token = "93D2C537-FA4A-448C-90A9-6058CF26DB29"
	}
	
	func testFetchTransactionsSuccess() async {
		//Given
		viewModel.isLoading = false
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertNil(viewModel.networkError)
		XCTAssertEqual(viewModel.totalAmount, 12345.67)
		XCTAssertEqual(viewModel.totalTransactions.count, 5)
		XCTAssertEqual(viewModel.recentTransactions.count, 3)
		XCTAssertFalse(viewModel.isLoading)
	}
	
	func testFetchTransactionsFail() async {
		//Given
		dataMock.validResponse = false
		viewModel.isLoading = false
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertEqual(viewModel.totalAmount, 0.00)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions.count, 0)
	}
	
	func testFetchTransactionsFailInvalidToken() async {
		//Given
		dataMock.validResponse = true
		viewModel.isLoading = false
		AuraService.token = nil
		//When
		await viewModel.fetchTransactions()
		//Then
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertEqual(viewModel.totalAmount, 0)
		XCTAssertEqual(viewModel.totalTransactions, [])
		XCTAssertEqual(viewModel.recentTransactions, [])
	}
	
	func testFormattedAmountSuccess() {
		//Given
		let value = Decimal(string: "12345.6789") //renvoie un optionnel
		//When
		let formattedValue = viewModel.formattedAmount(value: value!)
		//Then
		XCTAssertEqual(formattedValue, "12\u{202F}345,68") //u{202F}= espace insécable automatiquement ajouté par la locale francais entre lesmilliers
	}
	
	func testFormattedAmountFail() {
		let value: Decimal? = nil
		let formattedValue = viewModel.formattedAmount(value: value)
		XCTAssertEqual(formattedValue, "Invalid value")
	}
}

