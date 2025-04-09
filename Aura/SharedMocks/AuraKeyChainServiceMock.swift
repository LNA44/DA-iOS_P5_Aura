//
//  AuraKeyChainServiceTest.swift
//  AuraTests
//
//  Created by Ordinateur elena on 26/03/2025.
//
import Foundation
//import XCTest
//@testable import Aura

public class AuraKeyChainServiceMock {
	public var storedToken: String?
	
	public func storeToken(token: String, key: String) {
		storedToken = token
	}
	
	public func retrieveToken(key: String) -> String? {
		return storedToken
	}
	
	public func removeToken(key: String) {
		storedToken = nil
	}
}

