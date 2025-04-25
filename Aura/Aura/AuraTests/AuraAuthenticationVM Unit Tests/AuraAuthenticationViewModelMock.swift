//
//  AuraAuthenticationVMMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 18/04/2025.
//

import XCTest
@testable import Aura

enum MockScenarioAuthenticationViewModelRepository {
		case success
		case decodingAPIError
		case unknownError
	}
struct AuraAuthenticationViewModelMock {
	func makeMock(for scenario: MockScenarioAuthenticationViewModelRepository) -> (URLResponse?, Data?, Error?) {
		switch scenario {
		case .success:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/auth")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let jsonData = """
				{
					"token": "93D2C537-FA4A-448C-90A9-6058CF26DB29"
				}
			""".data(using: .utf8)!
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		case .decodingAPIError:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/auth")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let jsonData = Data()
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		case .unknownError:
			let error = NSError(domain: "test", code: 1, userInfo: nil)
			MockURLProtocol.requestHandler = { request in
				return (nil, nil, error) // Réponse simulée
			}
			
			return (nil, nil, error)
		}
	}
}
