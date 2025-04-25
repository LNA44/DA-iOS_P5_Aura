//
//  DataMoneyTransferMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 15/03/2025.
//

import XCTest
@testable import Aura

enum MockScenarioTransferMoneyViewModelRepository {
	case success
	case invalidResponseAPIError
	case unknownError
}

struct AuraMoneyTransferViewModelMock {
	func makeMock(for scenario: MockScenarioTransferMoneyViewModelRepository) -> (URLResponse?, Data?, Error?) {
		switch scenario {
		case .success:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/auth")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let jsonData = Data()
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		case .invalidResponseAPIError:
			let response = URLResponse(url: URL(string: "http://127.0.0.1:8080/auth")!,
									   mimeType: "application/json",
									   expectedContentLength: 0,
									   textEncodingName: "utf-8")
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
