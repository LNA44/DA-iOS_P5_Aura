//
//  AuraTransferMoneyRepositoryMock.swift
//  AuraTests
//
//  Created by Ordinateur elena on 17/04/2025.
//

import XCTest
@testable import Aura

final class AuraTransferMoneyRepositoryUnitTests: XCTestCase {
	let mockData = AuraTransferMoneyRepositoryMock()

	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	lazy var repository = MoneyTransferRepository(keychain: AuraKeychainService(), APIService: apiService)
	
	let token = "921DBEEB-9A66-475D-BEFD-3071B8E91AA0"
	
    override func setUp()  {
		_ = AuraKeychainService().saveToken(token: token, key: "authToken")
    }

    override func tearDown()  {
		super.tearDown()
		MockURLProtocol.requestHandler = nil
    }

	func testTransferMoneySuccess() async {
		//Given
		let recipient = "r@gmail.com"
		let amount = Decimal(100)
		
		_ = mockData.makeMock(for: .success)
		//When & Then
		do {
			_ = try await repository.transferMoney(recipient: recipient, amount: amount)
			XCTAssertTrue(true, "Transfer successful")
		} catch {
			XCTFail("Error shouldn't be thrown")
		}
	}
	
	func testTransferMoneyUnauthrorizedErrorOccurs() async {
		//Given
		_ = AuraKeychainService().deleteToken(key: "authToken")
		
		let recipient = "r@gmail.com"
		let amount = Decimal(100)
		
		_ = mockData.makeMock(for: .unauthorizedError)

		//When & Then
		do {
			_ = try await repository.transferMoney(recipient: recipient, amount: amount)
			XCTFail("An error should be thrown")
		} catch APIError.unauthorized {
			XCTAssertTrue(true, "Caught expected APIError.unauthorized")
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
}
