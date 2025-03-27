//
//  AuraServiceTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 25/03/2025.
//

import XCTest
@testable import Aura

final class AuraServiceLoginTests: XCTestCase {
	var dataMock = AuraServiceLoginMock()
	var repository: AuraService!
	let keychain = AuraKeyChainServiceMock()
	
	override func setUp() {
		super.setUp()
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
	}
	
	func testLoginSuccess() async throws {
		//Given
		dataMock.response = 1
		//When
		let token = try await repository.login(username: dataMock.username, password: dataMock.password)
		//Then
		XCTAssertEqual(token, "93D2C537-FA4A-448C-90A9-6058CF26DB29")
	}
	
	func testLoginBadURLShouldThrowBadURLError() async throws {
		//Given
		dataMock.response = 2
		repository = AuraService(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		//When & Then
		do {
			_ = try await repository.login(username: dataMock.username, password: dataMock.password)
			XCTFail("This should fail to load")
		} catch {
		} //Si aucun retour alors test OK
	}
	
	func testLoginNoDataErrorOccurs() async throws {
		//Given
		dataMock.response = 3
		//When & Then
		do {
			_ = try await repository.login(username: dataMock.username, password: dataMock.password)
			XCTFail("This should fail to load")
		} catch {
		}
	}
	
	func testLoginRequestFailedErrorOccurs() async {
		//Given
		dataMock.response = 4
		//When & Then
		do {
			_ = try await repository.login(username: dataMock.username, password: dataMock.password)
			XCTFail("This should fail to load")
		} catch {
		}
	}
	
	func testLoginServerErrorOccurs() async {
		//Given
		dataMock.response = 5
		//When & Then
		do {
			_ = try await repository.login(username: dataMock.username, password: dataMock.password)
			XCTFail("This should fail to load")
		} catch {
		}
	}
	
	func testLoginDecodingErrorOccurs() async {
		//Given
		dataMock.response = 6
		//When & Then
		do {
			_ = try await repository.login(username: dataMock.username, password: dataMock.password)
			XCTFail("This should fail to load")
		} catch {
		}
	}
}
