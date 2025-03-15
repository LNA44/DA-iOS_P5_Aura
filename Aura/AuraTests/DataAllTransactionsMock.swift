//
//  DataAllTransactionsMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class DataAllTransactionsMock {
	
	//MARK: -Properties
	//let tokenMock: String
	var isLoading: Bool = false
	var validResponse: Bool = true
	var currentBalance: Decimal
	let accountResponseMock: AccountResponse
	let transaction1: AccountResponse.Transaction
	let transaction2: AccountResponse.Transaction
	let transaction3: AccountResponse.Transaction
	let transaction4: AccountResponse.Transaction
	let transaction5: AccountResponse.Transaction
	
	//MARK: -Init
	init() {
		//tokenMock = "93D2C537-FA4A-448C-90A9-6058CF26DB29"
		transaction1 = AccountResponse.Transaction(value: -50, label: "Achat de maillot de foot")
		transaction2 = AccountResponse.Transaction(value: -1000, label: "Achat d'un vélo")
		transaction3 = AccountResponse.Transaction(value: -700, label: "Achat d'une mmontre")
		transaction4 = AccountResponse.Transaction(value: 10000, label: "Salaire")
		transaction5 = AccountResponse.Transaction(value: 3000, label: "Revenu appartements")
				
		currentBalance = 12345.67
		
		accountResponseMock = AccountResponse(transactions: [transaction1, transaction2, transaction3, transaction4, transaction5], currentBalance: currentBalance)
		
	}
	
	//MARK: -Methods
	
	private func encodeData(AuraResponseTypeMock :  AccountResponse) throws -> Data { //encode en Data : binaire
		return try JSONEncoder().encode(AuraResponseTypeMock)
	}
	
	func executeRequestMock(request: URLRequest) async throws -> (Data, URLResponse) {
		if validResponse {
			return try await validMockResponse(request: request)
		} else {
			return try await invalidMockResponse(request: request)
		}
	}
	
	func validMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let data = try encodeData(AuraResponseTypeMock : accountResponseMock)
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (data, response)
	}
	
	private func invalidMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "invalidJSON".data(using: .utf8)!
		let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
}
