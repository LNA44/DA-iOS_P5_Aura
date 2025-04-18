//
//  AuraAuthenticationRepository Unit Tests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 16/04/2025.
//

import XCTest
@testable import Aura

final class AuraAuthenticationRepositoryUnitTests: XCTestCase {
	
	let mockData = AuraAuthenticationRepositoryMock()

	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	lazy var repository = AuthenticationRepository(keychain: AuraKeychainService(), APIService: apiService)

    override func setUp() {
		super.setUp()
    }

    override func tearDown() {
		super.tearDown()
		MockURLProtocol.requestHandler = nil
    }

	func testLoginSuccess() async {
		//Given
		let (_,_,_) = mockData.makeMock(for: .success)
		
		let username = "test"
		let password = "test"
		//When & Then
		do {
			_ = try await repository.login(username: username, password: password)
		} catch {
			XCTFail("Should not throw an error")
		}
	}
	
	func testLoginNoDataErrorOccurs() async {
		//Given
		let (_,_,_) = mockData.makeMock(for: .noDataError)
		let username = "test"
		let password = "test"
		//When & Then
		do {
			_ = try await repository.login(username: username, password: password)
			XCTFail("Error should have occurred")
		} catch APIError.noData {
			XCTAssertTrue(true, "Caught expected APIError.noData")
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testLoginUnauthorizedErrorOccurs() async {
		//Given
		let (_,_,_) = mockData.makeMock(for: .unauthorizedError)
		let username = "test"
		let password = "test"
		//When & Then
		do {
			_ = try await repository.login(username: username, password: password)
			XCTFail("Error should have occurred")
		} catch APIError.unauthorized {
			XCTAssertTrue(true, "Caught expected APIError.unauthorized")
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}

}
