//
//  DataMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class DataMock {
	
	//MARK: -Properties
	let tokenMock: String
	var validResponse: Bool = true
	
	//MARK: -Init
	init() {
		tokenMock = "93D2C537-FA4A-448C-90A9-6058CF26DB29"
	}
	
	//MARK: -Methods
	
	func executeRequestMock(request: URLRequest) async throws -> (Data, URLResponse) {
		if validResponse {
			return try await validMockResponse(request: request)
		} else {
			return try await invalidMockResponse(request: request)
		}
	}
	
	func validMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let tokenDictionnary = ["token": tokenMock]
		let data = try JSONEncoder().encode(tokenDictionnary)
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (data, response)
	}
	private func invalidMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "invalidJSON".data(using: .utf8)!
		let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
}
