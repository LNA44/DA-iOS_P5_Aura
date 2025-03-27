//
//  DataAllTransactionsMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAccountDetailsMock {
	
	//MARK: -Properties
	var response: Int = 0
	var currentBalance: Decimal
	let accountResponseMock: AccountResponse
	let transaction1: AccountResponse.Transaction
	let transaction2: AccountResponse.Transaction
	let transaction3: AccountResponse.Transaction
	let transaction4: AccountResponse.Transaction
	let transaction5: AccountResponse.Transaction
	
	//MARK: -Init
	init() {
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
		if response == 1 {
			return try await validMockResponse(request: request)
		} else if response == 2 {
			return try await validMockResponse(request: request)
		} else if response == 3 {
			return try await validMockResponse(request: request)
		} else if response == 4 {
			return try await invalidMockResponseNoDataError(request: request)
		} else if response == 5 {
			return try await invalidMockResponseRequestFailedError(request: request)
		} else if response == 6 {
			return try await invalidMockResponseServerError(request: request)
		} else if response == 7 {
			return try await invalidMockResponseDecodingError(request: request)
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
	
	private func invalidMockResponseNoDataError(request: URLRequest) async throws -> (Data, URLResponse) {
		let noData = Data()
		let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		return (noData, response)
	}
	
	private func invalidMockResponseRequestFailedError(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "invalidJSON".data(using: .utf8)!
		let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
		return (invalidData, response)
	}
	
	private func invalidMockResponseServerError(request: URLRequest) async throws -> (Data, URLResponse) {
		let data = try encodeData(AuraResponseTypeMock : accountResponseMock)
		let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		return (data, response)
	}
	
	private func invalidMockResponseDecodingError(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "balance: 1234567890".data(using: .utf8)!
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
}
