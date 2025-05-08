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
		super.setUp()
			_ = try? AuraKeychainService().saveToken(token: token, key: Constante.MoneyTransfer.tokenKey)
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
}
