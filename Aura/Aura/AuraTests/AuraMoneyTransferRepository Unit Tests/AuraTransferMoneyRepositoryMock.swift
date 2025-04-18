//
//  AuraTransferMoneyRepositoryMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 17/04/2025.
//

import XCTest
@testable import Aura

enum MockScenarioMoneyTransferRepository {
	case success
	case unauthorizedError
}

final class AuraTransferMoneyRepositoryMock {
	func makeMock(for scenario: MockScenarioMoneyTransferRepository) -> (URLResponse?, Data?, Error?) {
		switch scenario {
		case .success:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account/transfer")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let jsonData = Data()
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			return (response, jsonData, nil)
			
		case .unauthorizedError:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account/transfer")!, statusCode: 200, httpVersion: nil, headerFields: nil)
			let jsonData = Data()
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil)
			}
			
			return (response, jsonData, nil)
		}
	}
}
