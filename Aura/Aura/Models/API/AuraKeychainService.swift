//
//  AuraKeyChainService.swift
//  Aura
//
//  Created by Ordinateur elena on 22/03/2025.
//

import Security
import Foundation

//Gère le token en le cryptant
class AuraKeychainService: ObservableObject {
	enum KeychainError: Error {
		case itemNotFound
		case duplicateItem
		case unexpectedStatus(OSStatus)
		case unexpectedData
		
		var errorKeychainDescription: String? {
			switch self {
			case .itemNotFound:
				return "Item was not found"
			case .duplicateItem:
				return "Item already exists"
			case .unexpectedStatus(let OSStatus):
				return "Unexpected status: \(OSStatus)"
			case .unexpectedData:
				return "Unexpected data received"
			}
		}
	}
		
	func saveToken(token: String, key: String) throws -> Bool {
		
		// Création de la requête pour définir les caractéristiques du Keychain
		var query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword, // Type d'élément
			kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock, // Accessibilité du token
			kSecAttrAccount as String: key, // Clé unique associée au token
		//	kSecAttrLabel as String: label // Utilisation de 'label' qui est égal à 'key'
		]
		// Conversion du token en Data (pour l'instant sous forme de String, il faut le convertir pour le Keychain)
		let tokenData = token.data(using: .utf8)!
		query[kSecValueData as String] = tokenData // On ajoute le token converti en Data à la requête

		// Tente de récupérer l'élément du Keychain
		var existingItem: CFTypeRef?
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &existingItem) //Ajoute les éléments du dico au keychain
		
		if status == errSecSuccess { // teste si l'élément existe déjà dans le keychain
			throw KeychainError.duplicateItem
		}
			// Mise à jour de l'élément existant avec les nouveaux attributs
			//let updateQuery: [String: Any] = [
			//	kSecValueData as String: tokenData, // Nouvelles données du token
				//kSecAttrLabel as String: label      // Le label reste le même
			//]
			// Update existing item
			//let statusUpdate = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary) //maj de l'élément : qui a la clé de recherche query (les caractéristiques) et on y remplace les attributs pour updateQuery
		
		// Tente d'ajouter l'élément au Keychain
			let addStatus: OSStatus = SecItemAdd(query as CFDictionary, nil)
			guard addStatus == errSecSuccess else { //si update echoue on lance erreur
				throw KeychainError.unexpectedStatus(addStatus)
			}
			return true
	}
	
	func getToken(key: String) throws -> String? { //on récupère un élément identifié par son label ou par des attributs (queryAttributes)
		let query: [String: Any] = [ //création requête
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecMatchLimit as String: kSecMatchLimitOne, //si plsrs éléments correspondent à la requête on ne prend que le premier
			kSecReturnAttributes as String: true,
			kSecReturnData as String: true
		]
		
		var item: CFTypeRef?
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item) //trouve élément correspondant à la query

		guard status != errSecItemNotFound else {
			throw KeychainError.itemNotFound
		}
		
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
		
		guard let item = item as? [String: Any],
			  let tokenData = item[kSecValueData as String] as? Data,
			  let token = String(data: tokenData, encoding: .utf8) else {
			throw KeychainError.unexpectedData
		}
		return token
	}
	
	func deleteToken(key: String) throws -> Bool {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
		]
		
		let status: OSStatus = SecItemDelete(query as CFDictionary)
		
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw KeychainError.unexpectedStatus(status)
		}
		return true
	}
}
