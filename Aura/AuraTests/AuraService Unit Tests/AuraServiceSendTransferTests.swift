//
//  AuraServiceSendMoneyTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 25/03/2025.
//

import XCTest
@testable import Aura

final class AuraServiceSendTransferTests: XCTestCase {
	
	var dataMock = AuraServiceSendMoneyMock()
	var repository: AuraService!
	let keychain = AuraKeyChainServiceMock()
	
	override func setUp() {
		super.setUp()
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		keychain.storeToken(token: "93D2C537-FA4A-448C-90A9-6058CF26DB29", key: "authToken")
	}
	
	override func tearDown() {
		keychain.removeToken(key: "authToken")
	}
	
	func testSendTransferSuccess() async {
		//Given
		dataMock.response = 1
		//When & Then
		do {
			_ = try await repository.transferMoney(recipient: dataMock.recipient, amount: dataMock.amount)
		} catch {
			XCTFail("Should not fail")
		}
	}
	
	func testSendTransferBadURLFail() async {
		//Given
		repository = AuraService(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		dataMock.response = 2
		//When
		do {
			_ = try await repository.transferMoney(recipient: dataMock.recipient, amount: dataMock.amount)
			XCTFail("Should not send money")
		} catch {
		}
	}
	
	func testSendTransferMissingTokenFail() async {
		//Given
		keychain.removeToken(key: "authToken")
		dataMock.response = 3
		//When
		do {
			_ = try await repository.transferMoney(recipient: dataMock.recipient, amount: dataMock.amount)
			XCTFail("Should not send money")
		} catch {
		}
	}
	
	func testSendTransferDataNotEmptyFail() async {
		//Given
		dataMock.response = 4
		//When
		do {
			_ = try await repository.transferMoney(recipient: dataMock.recipient, amount: dataMock.amount)
			XCTFail("Should not send money")
		} catch {
		}
	}
	
	func testSendTransferRequestFail() async {
		//Given
		dataMock.response = 5
		//When
		do {
			_ = try await repository.transferMoney(recipient: dataMock.recipient, amount: dataMock.amount)
			XCTFail("Should not send money")
		} catch {
		}
	}
	
	func testSendTransferServerFail() async {
		//Given
		dataMock.response = 6
		//When
		do {
			_ = try await repository.transferMoney(recipient: dataMock.recipient, amount: dataMock.amount)
			XCTFail("Should not send money")
		} catch {
		}
	}
}
