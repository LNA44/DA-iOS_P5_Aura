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
	
}
/*func convertAmount(amountString: String) {
	if let decimalAmount = Decimal(string: amountString) {
		self.amount = decimalAmount
	} else {
		self.amount = Decimal(0.0)
	}
}
*/
