//
//  AuraKeyChainService.swift
//  Aura
//
//  Created by Ordinateur elena on 22/03/2025.
//

//import Security
import KeychainSwift
import Foundation

/*protocol KeychainServiceProtocol {
	func storeToken(token: String, key: String)
	func retrieveToken(key: String) -> String?
	func removeToken(key: String)
}*/

//Gère le token en le cryptant
class AuraKeychainService: ObservableObject {
	
	private let keychain = KeychainSwift()
	
	// Sauvegarder un token
	func saveToken(token: String, key: String) -> Bool {
		return keychain.set(token, forKey: key)
	}
	
	// Récupérer un token
	func getToken(key: String) -> String? {
		return keychain.get(key)
	}
	
	// Supprimer un token
	func deleteToken(key: String) -> Bool {
		keychain.delete(key)
	}
}
