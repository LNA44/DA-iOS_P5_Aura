//
//  AuraServiceSendMoneyMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 25/03/2025.
//

import XCTest
@testable import Aura

final class AuraServiceSendMoneyMock {
	
	//MARK: -Properties
	var response: Int = 0
	let recipient: String
	let amount: Decimal
	
	//MARK: -Init
	init() {
		recipient = "+33767070707"
		amount = 100
	}
	
	//MARK: -Methods
	func executeRequestMock(request: URLRequest) async throws -> (Data, URLResponse) {
		if response == 1 {
			return try await validMockResponse(request: request)
		}else if response == 2 {
			return try await validMockResponse(request: request)
		} else if response == 3 {
			return try await validMockResponse(request: request)
		} else if response == 4 {
			return try await invalidMockResponseDataNotEmptyError(request: request)
		} else if response == 5 {
			return try await invalidMockResponseRequestError(request: request)
		} else if response == 6 {
			return try await invalidMockResponseServerError(request: request)
		} else {
			fatalError("Pas de response correcte définie")
		}
	}
	
	private func validMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let data = Data()
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (data, response)
	}
	
	private func invalidMockResponseDataNotEmptyError(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "invalidJSON".data(using: .utf8)!
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
	
	private func invalidMockResponseRequestError(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = Data()
		let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
		return (invalidData, response)
	}
	
	private func invalidMockResponseServerError(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = Data()
		let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
}
