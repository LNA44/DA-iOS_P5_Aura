//
//  DataMoneyTransferMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 15/03/2025.
//

import XCTest
@testable import Aura

final class DataMoneyTransferMock {
	
	//MARK: -Properties
	var validResponse: Bool = true
	
	//MARK: -Init
	init() {}
	
	//MARK: -Methods
	
	func executeRequestMock(request: URLRequest) async throws -> (Data, URLResponse) {
		if validResponse {
			return try await validMockResponse(request: request)
		} else {
			return try await invalidMockResponse(request: request)
		}
	}
	
	func validMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let data = Data()
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (data, response)
	}
	private func invalidMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "[]".data(using: .utf8)!
		let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
}
