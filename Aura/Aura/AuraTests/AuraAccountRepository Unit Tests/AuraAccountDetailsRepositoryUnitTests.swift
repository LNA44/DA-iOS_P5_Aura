//
//  AuraAccountDetailsRepositoryUnitTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 17/04/2025.
//

import XCTest
@testable import Aura

final class AuraAccountDetailsRepositoryUnitTests: XCTestCase {
	let mockData = AuraAccountDetailsRepositoryMock()
	
	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	lazy var repository = AccountRepository(keychain: AuraKeychainService(), APIService: apiService)
	
	let token = "921DBEEB-9A66-475D-BEFD-3071B8E91AA0"
	
	override func setUp() {
		super.setUp()
		do {
			_ = try AuraKeychainService().saveToken(token: token, key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be saved")
		}
	}
	
	override func tearDown() {
		super.tearDown()
		MockURLProtocol.requestHandler = nil
		do {
			_ = try AuraKeychainService().deleteToken(key: Constante.Account.tokenKey)
		} catch {
			XCTFail("Token was not able to be deleted")
		}
	}
	
	func testFetchAccountDetailsSuccess() async {
		//Given
		_ = mockData.makeMock(for: .success)
		//When & Then
		do {
			let responseJSON = try await repository.fetchAccountDetails()
			XCTAssertEqual(responseJSON.transactions.count, 2)
			XCTAssertEqual(responseJSON.transactions[0].value, -56)
			XCTAssertEqual(responseJSON.transactions[0].label, "IKEA")
			XCTAssertEqual(responseJSON.transactions[1].value, -10)
			XCTAssertEqual(responseJSON.transactions[1].label, "Starbucks")
			XCTAssertEqual(responseJSON.currentBalance, 100.0)
		} catch {
			XCTFail("Error shouldn't be thrown")
		}
	}
	
	func testFetchAccountDetailsUnauthorizedErrorOccurs() async {
		//Given
		do {
			_ = try AuraKeychainService().deleteToken(key: "authToken")
		} catch {
			XCTFail("Token was not able to be deleted")
		}
		_ = mockData.makeMock(for: .unauthorizedError)
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
			XCTFail("An error should be thrown")
		} catch APIError.unauthorized {
			XCTAssertTrue(true, "Caught expected APIError.unauthorized")
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
}
