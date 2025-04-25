//
//  AuraAccountDetailsRepositoryMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 17/04/2025.
//

import XCTest
@testable import Aura

enum MockScenarioAccountRepository {
	case success
}

final class AuraAccountDetailsRepositoryMock {
	func makeMock(for scenario: MockScenarioAccountRepository) -> (URLResponse?, Data?, Error?) {
		switch scenario {
		case .success:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let jsonData = """
			{
				"currentBalance": 100,
				"transactions": [
					{
						"value": -56,
						"label": "IKEA"
					},
					{
						"value": -10,
						"label": "Starbucks"
					}
				]
			}
			""".data(using: .utf8)!
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		}
	}
}
