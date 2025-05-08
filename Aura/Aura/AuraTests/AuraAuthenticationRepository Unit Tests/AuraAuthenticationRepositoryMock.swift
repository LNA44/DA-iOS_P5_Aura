//
//  AuraAuthenticationRepositoryMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 17/04/2025.
//

import XCTest
@testable import Aura

enum MockScenarioAuthenticationRepository {
	case success
}

struct AuraAuthenticationRepositoryMock {
	func makeMock(for scenario: MockScenarioAuthenticationRepository) -> (URLResponse?, Data?, Error?) {
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
		}
	}
}
