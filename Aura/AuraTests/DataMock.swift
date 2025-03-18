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
	var response: Int = 0
	var parameters: [String: Any] = [
		"username": "test@aura.app",
		"password": "test123",
		"invalidObject": { return "This is a function" }
	]
	
	//MARK: -Init
	init() {
		tokenMock = "93D2C537-FA4A-448C-90A9-6058CF26DB29"
	}
	
	//MARK: -Methods
	
	func executeRequestMock(request: URLRequest) async throws -> (Data, URLResponse) {
		print("executeRequestMock utilisé")
		if response == 1 {
			print("executeRequestMock response = 1 utilisé")
			return try await validMockResponse(request: request)
		} else if response == 2 {
			print("executeRequestMock response = 2 utilisé")
			return try await validMockResponse(request: request)
		} else if response == 3 {
			print("executeRequestMock response = 3 utilisé")
			return try await invalidMockResponseNoDataError(request: request)
		} else if response == 4 {
			print("executeRequestMock response = 4 utilisé")
			return try await invalidMockResponseRequestFailedError(request: request)
		} else if response == 5 {
			print("executeRequestMock response = 5 utilisé")
			return try await invalidMockResponseServerError(request: request)
		} else if response == 6 {
			print("executeRequestMock response = 6 utilisé")
			return try await invalidMockResponseDecodageError(request: request)
		} else {
			fatalError("Pas de response correcte définie")
		}
	}
	
	private func validMockResponse(request: URLRequest) async throws -> (Data, URLResponse) {
		let tokenDictionnary = ["token": tokenMock]
		print("token utilisé : \(tokenMock)")
		let data = try JSONEncoder().encode(tokenDictionnary)
		print("token encodé : \(data)")
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (data, response)
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
		let tokenDictionnary = ["token": tokenMock]
		let data = try JSONEncoder().encode(tokenDictionnary)
		let invalidResponse = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		print("response: \(response)")
		return (data, invalidResponse)
	}
	
	private func invalidMockResponseDecodageError(request: URLRequest) async throws -> (Data, URLResponse) {
		let invalidData = "token: 1234567890".data(using: .utf8)!
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (invalidData, response)
	}
}
