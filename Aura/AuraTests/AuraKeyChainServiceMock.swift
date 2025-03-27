//
//  AuraKeyChainServiceTest.swift
//  AuraTests
//
//  Created by Ordinateur elena on 26/03/2025.
//

import XCTest
@testable import Aura

class AuraKeyChainServiceMock: KeyChainServiceProtocol {
	var storedToken: String?
	
	func storeToken(token: String, key: String) {
		storedToken = token
	}
	
	func retrieveToken(key: String) -> String? {
		return storedToken
	}
	
	func removeToken(key: String) {
		storedToken = nil
	}
}

