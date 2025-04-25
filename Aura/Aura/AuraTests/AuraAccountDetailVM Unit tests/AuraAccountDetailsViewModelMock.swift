//
//  DataAllTransactionsMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura
	
enum MockScenarioAccountDetailsViewModelRepository {
	case success
	case noDataAPIError
	case unknownError
}

struct AuraAccountDetailsViewModelMock {
	func makeMock(for scenario: MockScenarioAccountDetailsViewModelRepository) -> (URLResponse?, Data?, Error?) {
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
						
					},
					{
						"value": -32,
						"label": "SuperU"
					},
					{
						"value": -70,
						"label": "Zara"
					}
				]
			}
			""".data(using: .utf8)!
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		case .noDataAPIError:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account")!,
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
